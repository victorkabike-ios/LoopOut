//
//  SimilarPhotoCategorizationHelper.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/06.
//

import Foundation
import SwiftUI
import Photos
import CoreML
import Vision
import UIKit
import VideoToolbox

class SimilarPhotoCategorizationHelper {
    static let model = try! VNCoreMLModel(for: Resnet50().model)
    
    static func category(for image: UIImage, confidenceThreshold: Float = 0.5) -> String? {
        var category: String?
        
        guard let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) else { return nil }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            // Filter results based on confidence threshold
            let filteredResults = results.filter { $0.confidence >= confidenceThreshold }
            
            if let highestConfidenceResult = filteredResults.max(by: { $0.confidence < $1.confidence }) {
                category = highestConfidenceResult.identifier
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
        return category
    }
}
