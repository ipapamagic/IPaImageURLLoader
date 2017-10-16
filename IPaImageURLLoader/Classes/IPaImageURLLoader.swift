//
//  IPaImageURLLoader.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
import IPaSecurity
import IPaLog
let IPA_NOTIFICATION_IMAGE_LOADED = "IPA_NOTIFICATION_IMAGE_LOADED"
let IPA_NOTIFICATION_IMAGE_LOAD_FAIL = "IPA_NOTIFICATION_IMAGE_LOAD_FAIL"
let IPA_NOTIFICATION_KEY_IMAGEFILEURL = "IPA_NOTIFICATION_KEY_IMAGEFILEURL"
let IPA_NOTIFICATION_KEY_IMAGEID = "IPA_NOTIFICATION_KEY_IMAGEID"
let IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER = 3


@objc public protocol IPaImageURLLoaderDelegate : AnyObject {
    func onIPaImageURLLoader(loader:IPaImageURLLoader,imageID:String,imageFileURL:URL)
    func onIPaImageURLLoaderFail(loader:IPaImageURLLoader, imageID:String)
    func getCacheFilePath(loader:IPaImageURLLoader,imageID:String) -> String
    func modifyImage(loader:IPaImageURLLoader,originalImageFileURL:URL?,imageID:String) -> UIImage?
}
@objc open class IPaImageURLLoader :NSObject,IPaImageURLLoaderDelegate,IPaImageURLBlockHandlerDelegate {
    static public let sharedInstance = IPaImageURLLoader()
    let operationQueue = OperationQueue()
    var blockHandlers = [IPaImageURLBlockHandler]()
    open weak var delegate:IPaImageURLLoaderDelegate!
    lazy var session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var cachePath:String
    var maxConcurrent:Int {
        get {
            return operationQueue.maxConcurrentOperationCount
        }
        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }
    override public init() {
        
        operationQueue.maxConcurrentOperationCount = IPA_IMAEG_LOADER_MAX_CONCURRENT_NUMBER
        cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] ;
        cachePath = (cachePath as NSString).appendingPathComponent("cacheImage")
        let fileMgr = FileManager.default
        if !fileMgr.fileExists(atPath: cachePath) {
            var error:NSError?
            do {
                try fileMgr.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            if let error = error {
                print(error)
            }
        }
        super.init()
        delegate = self
        
    }

    open func cacheWithImageID(_ imageID:String) -> UIImage? {
        if let path = delegate?.getCacheFilePath(loader: self, imageID: imageID)
        {
            return UIImage(contentsOfFile: path)
        }
        return nil;

    }
    open func cacheDataWithImageID(_ imageID:String) -> NSData? {
        if let path = delegate?.getCacheFilePath(loader: self, imageID: imageID)
        {
            return NSData(contentsOfFile: path)
        }
        return nil;
    }
    open func loadImageData(url:String,imageID:String) -> NSData? {
        if let data = cacheDataWithImageID(imageID) {
            return data
        }
        doLoadImage(url: url, imageID: imageID)
        return nil
    }
    open func loadImage(url:String,imageID:String) -> UIImage? {
        
        if let image = cacheWithImageID(imageID) {
            return image
        }
        doLoadImage(url: url, imageID: imageID)
        
        
        return nil
    }
    open func loadImage(url:String,imageID:String,handler:@escaping (UIImage?) -> ()) {
        if let image = cacheWithImageID(imageID) {
            handler(image)
            return
        }
        let blockHandler = IPaImageURLBlockHandler(imageURL: url,imageID:imageID, block: handler)
        blockHandler.delegate = self
        blockHandlers.append(blockHandler)
        doLoadImage(url: url, imageID: imageID)
        
        
    }
    open func loadImage(url:String,handler:@escaping (UIImage?) -> ()) {
        self.loadImage(url: url, imageID: url, handler: handler)
    }
    func doLoadImage(url:String,imageID:String) {
        
        let currentQueue = operationQueue.operations
        var index = NSNotFound
        var count:Int = 0
        for operation in currentQueue {
            let imgOperation = operation as! IPaImageURLOperation
            if imgOperation.imageID == imageID {
                index = count
                break
            }
            count += 1
        }
        if index != NSNotFound {
            let operation = currentQueue[index] as! IPaImageURLOperation
            if !operation.isCancelled {
                if operation.request.url?.absoluteString != url {
                    operation.cancel()
                }
                
            }
            
        }
        if let url = URL(string:url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let operation = IPaImageURLOperation(request: request, imageID: imageID, session: session)
            operation.completionBlock = {
                //        UIImage *image = weakOperation.loadedImage;
                var imageURL = operation.loadedImageFileURL
                
                if let modifyImage = self.delegate?.modifyImage(loader: self, originalImageFileURL: imageURL, imageID: imageID) {
                    
                    
                    var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
                    path = (path as NSString).appendingPathComponent("IPaImageCache.imageCache")
                    let data = UIImagePNGRepresentation(modifyImage)!
                    
                    let pathURL = URL(fileURLWithPath:path)
                    do {
                        try data.write(to: pathURL)
                    }
                    catch let e as NSError{
                        IPaLog(e.debugDescription)
                    }
                    
                    
                    
                    imageURL = URL(fileURLWithPath: path);
                }
                
                
                if let imageURL = imageURL {
                    if let path = self.delegate?.getCacheFilePath(loader: self, imageID: imageID) {
                        
                        let directory = (path as NSString).deletingLastPathComponent
                        let fileManager = FileManager.default

                        if !fileManager.fileExists(atPath: directory) {
                            
                            
                            do {
                                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                            } catch _ as NSError {
                                return
                            } catch {
                                fatalError()
                            }
                            
                        }
                        do {
                            if fileManager.fileExists(atPath: path) {
                                try fileManager.removeItem(atPath: path)
                            }
                            try fileManager.copyItem(at: imageURL, to:(URL(fileURLWithPath:path)))

                        } catch let error as NSError {
                            IPaLog(error.debugDescription)
                            return
                        } catch {
                            fatalError()
                        }
                        
                        
                    }
                   
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: IPA_NOTIFICATION_IMAGE_LOADED), object: nil, userInfo: [IPA_NOTIFICATION_KEY_IMAGEFILEURL:imageURL,IPA_NOTIFICATION_KEY_IMAGEID:imageID])
                    self.delegate.onIPaImageURLLoader(loader: self, imageID: imageID, imageFileURL: imageURL)
                    
                
                }
                else {
                   
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: IPA_NOTIFICATION_IMAGE_LOAD_FAIL), object: nil, userInfo: [IPA_NOTIFICATION_KEY_IMAGEID:imageID])
                    
                }
                
                
            }
            operationQueue.addOperation(operation)
        }
    }
    
    func cancelLoaderWithImageID(imageID:String) {
        
        let currentQueue = operationQueue.operations
        var index = NSNotFound
        var count:Int = 0
        for operation in currentQueue {
            let imgOperation = operation as! IPaImageURLOperation
            if imgOperation.imageID == imageID {
                index = count
                break
            }
            count += 1
        }
        if index != NSNotFound {
            let operation = currentQueue[index] as! IPaImageURLOperation
            
            operation.cancel()
            
        }
    
    }
    open func cancelAllOperation (){
        operationQueue.cancelAllOperations()
    }

//MARK :IPaImageURLBlockHandlerDelegate
    func onHandlerComplete(handler: IPaImageURLBlockHandler) {
        if let index = blockHandlers.index(of: handler) {
            blockHandlers.remove(at: index)
        }
    }
    
// MARK:IPaImageURLLoaderDelegate

    public func onIPaImageURLLoader(loader:IPaImageURLLoader,imageID:String,imageFileURL:URL)
    {
        
    }
    public func onIPaImageURLLoaderFail(loader:IPaImageURLLoader, imageID:String)
    {
        
    }
    public func getCacheFilePath(loader:IPaImageURLLoader,imageID:String) -> String
    {
        
        let filePath = (cachePath as NSString).appendingPathComponent("\(imageID.md5String!)")
        return filePath;
    }
    public func modifyImage(loader:IPaImageURLLoader,originalImageFileURL:URL?,imageID:String) -> UIImage?
    {
        return nil
    }
}
