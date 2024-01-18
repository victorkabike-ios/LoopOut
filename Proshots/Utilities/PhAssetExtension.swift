//
//  PhAssetExtension.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/15.
//

import SwiftUI
import Photos

extension PHAsset {
    func toUIImageV1() -> UIImage {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let targetSize = CGSize(width: 100, height: 100)
        var image: UIImage = UIImage()
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
            if let result = result {
                image = result
            }
        }

        return image
    }
    func toUIImage() -> UIImage {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        let targetSize = PHImageManagerMaximumSize
        var image: UIImage = UIImage()
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
            if let result = result {
                image = result
            }
        }

        return image
    }
    func getUIImage() -> UIImage {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                image = result!
            })
            return image
        }
}

