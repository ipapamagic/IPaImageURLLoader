//
//  IPaImageURLOperation.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/14.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
@objc class IPaImageURLOperation : Operation {
    var loadedImageFileURL:URL?
    let imageID:String
    var request:URLRequest
    var task:URLSessionDownloadTask?
    weak var session:URLSession?
    var _finished:Bool = false
    override var isExecuting:Bool {
        get {
            return !isFinished && (task != nil && task!.state == .running)
        }
        
    }
    
    override var isFinished:Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    override var isConcurrent:Bool {
        get {
            return true
        }
    }
    init(request:URLRequest,imageID:String,session:URLSession) {
        self.request = request
        self.imageID = imageID
        self.session = session
    }
    override func start() {
        if isCancelled
        {
            isFinished = true
            return;
        }
        self.willChangeValue(forKey: "isExecuting")
        task = session?.downloadTask(with: request, completionHandler: {(location,response,error) in
            if error == nil {
                if self.isCancelled {
                    return
                }
                guard let location = location else {
                    return
                }
                //move file to cache first
                var cachePath:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
                
                cachePath = (cachePath as NSString).appendingPathComponent(location.lastPathComponent)
                let toURL = URL(fileURLWithPath: cachePath)
                
                do {
                    try FileManager.default.copyItem(at: location, to: toURL)
                } catch {
                    fatalError()
                }
                self.loadedImageFileURL = toURL
            }
            self.willChangeValue(forKey: "isExecuting")
            self.isFinished = true
            self.didChangeValue(forKey: "isExecuting")
            
        })
        task?.resume()
        self.didChangeValue(forKey: "isExecuting")
        
    }
    override func cancel() {
        super.cancel()
        if isExecuting {
            self.willChangeValue(forKey: "isExecuting")
            self.isFinished = true
            task?.cancel()
            task = nil
            self.didChangeValue(forKey: "isExecuting")
            
        }
    }
}
