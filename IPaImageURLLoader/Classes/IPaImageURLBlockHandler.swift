//
//  IPaImageURLBlockHandler.swift
//  Pods
//
//  Created by IPa Chen on 2017/1/4.
//
//

import UIKit
protocol IPaImageURLBlockHandlerDelegate
{
    func onHandlerComplete(handler:IPaImageURLBlockHandler)
}
class IPaImageURLBlockHandler: NSObject {
    var delegate:IPaImageURLBlockHandlerDelegate!
    fileprivate var completeBlock:(UIImage?) -> ()
    var imageURL:String
    var imageID:String
    fileprivate var imageObserver:NSObjectProtocol?
    fileprivate var failObserver:NSObjectProtocol?
    convenience init(imageURL:String,block:@escaping (UIImage?) -> ()) {
        self.init(imageURL: imageURL, imageID: imageURL, block: block)
    }
    init(imageURL:String,imageID:String,block:@escaping (UIImage?) -> ()) {
        
        self.imageURL = imageURL
        self.imageID = imageID
        self.completeBlock = block
        super.init()
        createImageObserver()
        if let image = IPaImageURLLoader.sharedInstance.loadImage(url: (imageURL as NSString).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!, imageID: imageID)
        {
            completeBlock(image)
        }
    }
    deinit {
        if let imageObserver = imageObserver {
            NotificationCenter.default.removeObserver(imageObserver)
        }
        if let failObserver = failObserver {
            NotificationCenter.default.removeObserver(failObserver)
        }
    }
    func imageLoaded(imageID:String,image:UIImage?) -> Bool {
        if imageID == self.imageURL {
            completeBlock(image)
            return true
        }
        return false
    }
    func createImageObserver () {
        if imageObserver != nil {
            NotificationCenter.default.removeObserver(imageObserver!)
        }
        if failObserver != nil {
            NotificationCenter.default.removeObserver(failObserver!)
        }
        
        imageObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: IPA_NOTIFICATION_IMAGE_LOADED), object: nil, queue: OperationQueue.main, using: {
            noti in
            
            
            if let userInfo = (noti as NSNotification).userInfo {
                let imageID = userInfo[IPA_NOTIFICATION_KEY_IMAGEID] as! String
                if imageID == self.imageID {
                    if let data = try? Data(contentsOf: userInfo[IPA_NOTIFICATION_KEY_IMAGEFILEURL] as! URL ) {
                        
                        self.completeBlock(UIImage(data: data))
                        self.delegate.onHandlerComplete(handler: self)
                    }
                }
                
            }
        })
        failObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: IPA_NOTIFICATION_IMAGE_LOAD_FAIL), object: nil, queue: OperationQueue.main, using: {
            noti in
            self.completeBlock(nil)
            self.delegate.onHandlerComplete(handler: self)
        })
    }
}
