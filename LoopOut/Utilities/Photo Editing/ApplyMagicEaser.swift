//
//  ApplyMagicEaser.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/24.
//

import Foundation
import SwiftUI
import CoreImage
import UIKit


func applyMagicEraser(to image: UIImage, in rect: CGRect) -> UIImage? {
    // Convert the UIImage to a CIImage
    guard let ciImage = CIImage(image: image) else {
        return nil
    }

    // Create a mask that covers the selected part of the image
    let mask = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 1)).cropped(to: rect)

    // Apply the mask to the image
    let maskedImage = ciImage.applyingFilter("CIBlendWithMask", parameters: [kCIInputImageKey: ciImage, kCIInputMaskImageKey: mask])

    // Apply the magic eraser effect to the masked part of the image
    let magicEraserFilter = CIFilter(name: "CIMaskToAlpha")
    magicEraserFilter?.setValue(maskedImage, forKey: kCIInputImageKey)
    guard let outputCIImage = magicEraserFilter?.outputImage else {
        return nil
    }

    // Convert the CIImage back to a UIImage
    let context = CIContext(options: nil)
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
        return nil
    }

    return UIImage(cgImage: outputCGImage)
}
func createMaskImage(size: CGSize, selectedRect: CGRect) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }
    
    // Fill the entire context with a solid color (e.g., black)
    context.setFillColor(UIColor.black.cgColor)
    context.fill(CGRect(origin: .zero, size: size))
    
    // Clear the selected region by setting it to transparent
    context.setBlendMode(.clear)
    context.fill(selectedRect)
    
    // Create an image from the context
    let maskImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return maskImage
}
