//
//  ResizableView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/13.
//

import Foundation
import Photos
import SwiftUI
import CoreGraphics
import UIKit
import MediaToolbox
import MobileCoreServices
enum ResizeOption {
    case fit
    case fill
}

class ResizerManager: NSObject {
    func centerCrop(image: UIImage, cropRatio: CGSize) -> UIImage {
        let targetAspectRatio = cropRatio.width / cropRatio.height
        let sourceAspectRatio = image.size.width / image.size.height
        
        var cropRect = CGRect.zero
        
        if targetAspectRatio > sourceAspectRatio {
            let sideLength = image.size.height * targetAspectRatio
            let xOffset = (image.size.width - sideLength) / 2.0
            cropRect = CGRect(x: xOffset, y: 0, width: sideLength, height: image.size.height)
        } else {
            let sideLength = image.size.width / targetAspectRatio
            let yOffset = (image.size.height - sideLength) / 2.0
            cropRect = CGRect(x: 0, y: yOffset, width: image.size.width, height: sideLength)
        }
        
        if let sourceCGImage = image.cgImage, let croppedCGImage = sourceCGImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return image
        }
    }
    func resizeImage(_ image: UIImage, targetSize: CGSize, resizeOption: ResizeOption) -> UIImage? {
            var newSize = targetSize
            var drawRect = CGRect.zero

            let widthRatio = targetSize.width / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            switch resizeOption {
            case .fill:
                if widthRatio > heightRatio {
                    newSize.height = targetSize.width / image.size.width * image.size.height
                } else {
                    newSize.width = targetSize.height / image.size.height * image.size.width
                }
                drawRect.size = newSize
                
            case .fit:
                if widthRatio < heightRatio {
                    newSize.height = targetSize.width / image.size.width * image.size.height
                } else {
                    newSize.width = targetSize.height / image.size.height * image.size.width
                }
                drawRect.origin.x = (targetSize.width - newSize.width) / 2
                drawRect.origin.y = (targetSize.height - newSize.height) / 2
                drawRect.size = newSize
            }
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let resizedImage = renderer.image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: targetSize))
                image.draw(in: drawRect)
            }
            
            return resizedImage
        }
}

