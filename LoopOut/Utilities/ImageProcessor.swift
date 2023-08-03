//
//  ImageProcessor.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/16.
//

import Foundation
import SwiftUI
import Vision
import CoreML

class ImageProcessor: ObservableObject {
    private let model: VNCoreMLModel
    @Published var processedImage: UIImage?
    
    init() {
        guard let model = try? VNCoreMLModel(for: realesrgan512(configuration: MLModelConfiguration()).model) else {
            fatalError("Model initialization failed")
        }
        self.model = model
    }
    
    func processImage(_ image: UIImage){
        guard let pixelBuffer = image.pixelBuffer() else {
            return
        }
        
        let coreMLRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNPixelBufferObservation],
                  let outputImage = results.first?.pixelBuffer else {
                return
            }
            
            DispatchQueue.main.async {
                self?.processedImage = UIImage(pixelBuffer: outputImage)
            }
        }
        coreMLRequest.imageCropAndScaleOption = .scaleFill
        
        do {
            let handler = try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([coreMLRequest])
        } catch {
            print("Image processing error: \(error)")
        }
    }
}
