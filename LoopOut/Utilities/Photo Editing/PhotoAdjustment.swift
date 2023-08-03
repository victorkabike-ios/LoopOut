//
//  PhotoAdjustment.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/20.
//

import CoreImage
import UIKit

class PhotoAdjustment {
    private var context: CIContext
    
    init() {
        context = CIContext()
    }
    
    func adjustBrightness(image: UIImage, value: Float) -> UIImage? {
        return applyFilter(image: image, filterName: "CIColorControls", parameters: [kCIInputBrightnessKey: value])
    }
    
    func adjustContrast(image: UIImage, value: Float) -> UIImage? {
        return applyFilter(image: image, filterName: "CIColorControls", parameters: [kCIInputContrastKey: value])
    }
    
    func adjustSaturation(image: UIImage, value: Float) -> UIImage? {
        return applyFilter(image: image, filterName: "CIColorControls", parameters: [kCIInputSaturationKey: value])
    }
    func adjustVibrance(image: UIImage, value: Float) -> UIImage? {
            return applyFilter(image: image, filterName: "CIVibrance", parameters: [kCIInputAmountKey: value])
        }
    func adjustWarmth(image: UIImage, value: Float) -> UIImage? {
        return applyFilter(image: image, filterName: "CIWhitePointAdjust", parameters: ["inputNeutral": CIVector(x: CGFloat(value), y: 0)])
        }
        
    func adjustTint(image: UIImage, value: Float) -> UIImage? {
        return applyFilter(image: image, filterName: "CIWhitePointAdjust", parameters: ["inputNeutral": CIVector(x: 0, y: CGFloat(value))])
       }
        
        func adjustSharpness(image: UIImage, value: Float) -> UIImage? {
            return applyFilter(image: image, filterName: "CISharpenLuminance", parameters: [kCIInputSharpnessKey: value])
        }
        
    func adjustDenoise(image: UIImage, value: Float) -> UIImage? {
            return applyFilter(image: image, filterName: "CINoiseReduction", parameters: ["inputNoiseLevel": value])
        }
    // Add other adjustment methods here...
    
    private func applyFilter(image: UIImage, filterName: String, parameters: [String: Any]) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: filterName)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        for (key, value) in parameters {
            filter?.setValue(value, forKey: key)
        }
        
        guard let outputImage = filter?.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
