//
//  ImageProcessingHelper.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/17.
//

import Foundation
import SwiftUI
import CoreImage


/* Denoising: Image denoising techniques can help reduce noise and improve the clarity of the image. One popular denoising algorithm is the Non-Local Means Denoising algorithm. You can use the Core Image framework in Swift to apply this algorithm */

func denoiseImage(_ image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let denoiseFilter = CIFilter(name: "CINoiseReduction")!
    denoiseFilter.setValue(ciImage, forKey: kCIInputImageKey)
    denoiseFilter.setValue(0.1, forKey: "inputNoiseLevel")
    denoiseFilter.setValue(0.5, forKey: "inputSharpness")
    
    guard let outputCIImage = denoiseFilter.outputImage else { return nil }
    
    let context = CIContext()
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}

/* Contrast adjustment: Adjusting the contrast of the image can help enhance the details and make the foreground objects stand out. You can use the Core Image framework to apply contrast adjustment
 */

func adjustContrast(_ image: UIImage, contrast: CGFloat) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let contrastFilter = CIFilter(name: "CIColorControls")!
    contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
    contrastFilter.setValue(contrast, forKey: kCIInputContrastKey)
    
    guard let outputCIImage = contrastFilter.outputImage else { return nil }
    
    let context = CIContext()
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}

/* Sharpening: Sharpening the image can enhance the edges and details, which can be beneficial for background removal. You can use the Core Image framework to apply sharpening
 */


func sharpenImage(_ image: UIImage, intensity: CGFloat) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let sharpenFilter = CIFilter(name: "CISharpenLuminance")!
    sharpenFilter.setValue(ciImage, forKey: kCIInputImageKey)
    sharpenFilter.setValue(intensity, forKey: kCIInputSharpnessKey)
    
    guard let outputCIImage = sharpenFilter.outputImage else { return nil }
    
    let context = CIContext()
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}

/*Smoothing: You can apply a smoothing filter to the mask to remove any jagged edges or noise. This can be done using the Core Image framework in Swift
 */

func smoothImage(_ image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let filter = CIFilter(name: "CIMedianFilter")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    
    guard let outputCIImage = filter?.outputImage,
          let outputCGImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}


/*Morphological operations: You can apply morphological operations like dilation or erosion to refine the mask. This can help fill in small holes in the mask or remove small isolated regions
 */


func dilateImage(_ image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let filter = CIFilter(name: "CIDilate")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setValue(5.0, forKey: kCIInputRadiusKey) // Adjust this value as needed
    
    guard let outputCIImage = filter?.outputImage,
          let outputCGImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}

