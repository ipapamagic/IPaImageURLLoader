//
//  IPaImageURLButton.swift
//  IPaImageURLLoader
//
//  Created by IPa Chen on 2015/6/16.
//  Copyright (c) 2015年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
import IPaDownloadManager
@objc open class IPaImageURLButton : IPaDesignableButton {
    private var _imageURL:String?
    private var _backgroundImageURL:String?
    @objc open var imageURL:String? {
        get {
            return _imageURL
        }
        set {
            setImageURL(newValue, defaultImage: nil)
        }
    }
    @objc open var backgroundImageURL:String? {
        get {
            return _backgroundImageURL
        }
        set {
            setBackgroundImageURL(newValue, defaultImage: nil)
        }
    }
    deinit {
    }
    

    @objc open func setImageURL(_ imageURL:String?,defaultImage:UIImage?) {
        _imageURL = imageURL
        if let imageURLString = imageURL,let imageUrl = URL(string: imageURLString) {
            IPaDownloadManager.shared.download(from: imageUrl, fileId: imageURLString) { result in
                switch (result) {
                case .failure( _):
                    self.setImage(defaultImage, for: .normal)
                    break
                case .success(let url):
                    let image = UIImage(contentsOfFile: url.absoluteString)
                    self.setImage((image == nil) ? defaultImage :image, for: .normal)
                    break
                }
            }
        }
        else {
            self.setImage(defaultImage, for: .normal)
        }
    }
    @objc open func setBackgroundImageURL(_ imageURL:String?,defaultImage:UIImage?) {
        if let imageURLString = imageURL,let imageUrl = URL(string: imageURLString) {
            IPaDownloadManager.shared.download(from: imageUrl, fileId: imageURLString) { result in
                switch (result) {
                case .failure( _):
                    self.setBackgroundImage(defaultImage, for: .normal)
                    break
                case .success(let url):
                    let image = UIImage(contentsOfFile: url.absoluteString)
                    self.setBackgroundImage((image == nil) ? defaultImage :image, for: .normal)
                    break
                }
            }
        }
        else {
            self.setBackgroundImage(defaultImage, for: .normal)
        }
    }
}

