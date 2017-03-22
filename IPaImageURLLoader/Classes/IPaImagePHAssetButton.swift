//
//  IPaImagePHAssetButton.swift
//  Pods
//
//  Created by IPa Chen on 2017/3/19.
//
//

import UIKit
import Photos
@objc open class IPaImagePHAssetButton: UIButton {
    fileprivate var requestIndifier = ""
    open var asset:PHAsset?
        {
        didSet {
            guard let asset = asset else {
                self.setImage(nil, for: .normal)
                return
            }
            if oldValue == asset {
                return
            }
            let scale = UIScreen.main.scale
            let rect = self.bounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            self.requestIndifier = asset.localIdentifier
            PHCachingImageManager().requestImage(for: asset, targetSize: rect.size, contentMode: .aspectFill, options: nil, resultHandler:  {
                resultImage,info in
                if self.requestIndifier == asset.localIdentifier {
                    self.setImage(resultImage, for: .normal)
                }
            })
        }
    }
}
