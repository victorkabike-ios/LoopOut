//
//  PhotoUsageServices.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/27.
//

import Foundation
import SwiftUI
import UIKit
import Photos
import PhotosUI

class  CorePhotoController: NSObject, ObservableObject {
    func shareImage(image: UIImage) {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    func addImageToFavorites(asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest(for: asset)
            changeRequest.isFavorite = true
        }) { success, error in
            if success {
                print("Image added to favorites successfully.")
            } else if let error = error {
                print("Error adding image to favorites: \(error.localizedDescription)")
            } else {
                print("Failed to add image to favorites.")
            }
        }
    }
}
