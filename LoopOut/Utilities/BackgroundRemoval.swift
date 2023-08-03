//
//  BackgroundRemoval.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/16.
//

import Foundation
import Vision
import SwiftUI
import  CoreImage
import CoreML
struct GradientPoint {
   var location: CGFloat
   var color: UIColor
}

enum RemoveBackroundResult {
    case background
    case finalImage
    
}
class BackgroundRemoverISNet: ObservableObject {
    var outputImage : UIImage? = nil
//    private func getIS_NetModel() -> is_net? {
//        do {
//            let config = MLModelConfiguration()
//            return try is_net(configuration: config)
//        } catch {
//            print("Error loading model: \(error)")
//            return nil
//        }
//    }
    @Published var isRemoving:Bool = false
    func removeBackgroundDeepLabV3(from image:UIImage, returnResult: RemoveBackroundResult) -> UIImage? {
            guard let model = getDeepLabV3Model() else { return nil }
            let width: CGFloat = 513
            let height: CGFloat = 513
        let resizedImage = image.resized(to: CGSize(width: height, height: height), scale: 1)
            guard let pixelBuffer = resizedImage.pixelBuffer(width: Int(width), height: Int(height)),
            let outputPredictionImage = try? model.prediction(image: pixelBuffer),
            let outputImage = outputPredictionImage.semanticPredictions.image(min: 0, max: 1, axes: (0, 0, 1)),
            let outputCIImage = CIImage(image: outputImage),
            let maskImage = outputCIImage.removeWhitePixels(),
            let maskBlurImage = maskImage.applyBlurEffect() else { return nil }

            switch returnResult {
            case .finalImage:
                guard let resizedCIImage = CIImage(image: resizedImage),
                      let compositedImage = resizedCIImage.composite(with: maskBlurImage) else { return nil }
                let finalImage = UIImage(ciImage: compositedImage)
                    .resized(to: CGSize(width: image.size.width, height: image.size.height))
                return finalImage
            case .background:
                let finalImage = UIImage(
                    ciImage: maskBlurImage,
                    scale: image.scale,
                    orientation: image.imageOrientation
                ).resized(to: CGSize(width: image.size.width, height: image.size.height))
                return finalImage
            }
        }

        private func getDeepLabV3Model() -> DeepLabV3? {
            do {
                let config = MLModelConfiguration()
                return try DeepLabV3(configuration: config)
            } catch {
                print("Error loading model: \(error)")
                return nil
            }
        }
//
//    func removeBackground(from image: UIImage, returnResult: RemoveBackroundResult) -> UIImage? {
//        self.isRemoving = true
//        guard let model = getIS_NetModel() else { return nil }
//        let width: CGFloat = 1024
//        let height: CGFloat = 1024
//
//        let resizedImage = image.resized(to: CGSize(width: height, height: height), scale: 1)
//        guard let pixelBuffer = resizedImage.pixelBuffer(width: Int(width), height: Int(height)) else { return  nil }
//        guard let result = try? model.prediction(x_1: pixelBuffer) else { fatalError("inference error") }
//        let outputCIImage = CIImage(cvPixelBuffer: result.activation_out)
//        let maskImage = outputCIImage.removeWhitePixels()
//        let maskBlurImage = maskImage?.applyBlurEffect()
//
//        switch returnResult {
//        case .finalImage:
//            guard let resizedCIImage = CIImage(image: resizedImage),
//                  let compositedImage = resizedCIImage.composite(with: maskBlurImage!) else { return nil }
//            let finalImage = UIImage(ciImage: compositedImage)
//                .resized(to: CGSize(width: image.size.width, height: image.size.height))
//            self.isRemoving = false
//            return finalImage
//        case .background:
//            let finalImage = UIImage(
//                ciImage: maskBlurImage!,
//                scale: image.scale,
//                orientation: image.imageOrientation
//            ).resized(to: CGSize(width: image.size.width, height: image.size.height))
//            return finalImage
//        }
//    }
    func imageWithBackground(image: UIImage, backgroundColor: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let newImage = renderer.image { context in
            // Fill with background color
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: image.size))
            
            // Draw the original image with blend mode and alpha
            image.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .normal, alpha: 1.0)
        }
        
        return newImage
    }
    func imageWithBackground(image: UIImage, backgroundImage: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let newImage = renderer.image { context in
            // Draw the background image
            backgroundImage.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Draw the original image with blend mode and alpha
            image.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .normal, alpha: 1.0)
        }
        
        return newImage
    }
    func colorCorrectImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Apply color correction filters
        let colorCorrectFilter = CIFilter(name: "CIColorControls")!
        colorCorrectFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorCorrectFilter.setValue(1.2, forKey: kCIInputContrastKey)
        colorCorrectFilter.setValue(0.8, forKey: kCIInputSaturationKey)
        colorCorrectFilter.setValue(0.9, forKey: kCIInputBrightnessKey)
        
        // Get the output CIImage from the filter
        guard let outputCIImage = colorCorrectFilter.outputImage else { return nil }
        
        // Create a CIContext and convert the CIImage to a CGImage
        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        // Create a UIImage from the CGImage
        let correctedImage = UIImage(cgImage: outputCGImage)
        
        return correctedImage
    }


}


extension CIImage {
    func removeWhitePixels() -> CIImage? {
        let chromaCIFilter = chromaKeyFilter()
        chromaCIFilter?.setValue(self, forKey: kCIInputImageKey)
        return chromaCIFilter?.outputImage
    }

    func composite(with mask: CIImage) -> CIImage? {
        return CIFilter(
            name: "CISourceOutCompositing",
            parameters: [
                kCIInputImageKey: self,
                kCIInputBackgroundImageKey: mask
            ]
        )?.outputImage
    }

    func applyBlurEffect() -> CIImage? {
        let context = CIContext(options: nil)
        let clampFilter = CIFilter(name: "CIAffineClamp")!
        clampFilter.setDefaults()
        clampFilter.setValue(self, forKey: kCIInputImageKey)

        guard let currentFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        currentFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        currentFilter.setValue(2, forKey: "inputRadius")
        guard let output = currentFilter.outputImage,
              let cgimg = context.createCGImage(output, from: extent) else { return nil }

        return CIImage(cgImage: cgimg)
    }

    // modified from https://developer.apple.com/documentation/coreimage/applying_a_chroma_key_effect
    private func chromaKeyFilter() -> CIFilter? {
        let size = 64
        var cubeRGB = [Float]()

        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size - 1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size - 1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size - 1)
                    let brightness = getBrightness(red: red, green: green, blue: blue)
                    let alpha: CGFloat = brightness == 1 ? 0 : 1
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))

        let colorCubeFilter = CIFilter(
            name: "CIColorCube",
            parameters: [
                "inputCubeDimension": size,
                "inputCubeData": data
            ]
        )
        return colorCubeFilter
    }

    // modified from https://developer.apple.com/documentation/coreimage/applying_a_chroma_key_effect
    private func getBrightness(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var brightness: CGFloat = 0
        color.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }

}
