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
    func duplicatePhoto(asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges {
            guard PHAssetChangeRequest(for: asset.copy() as! PHAsset) != nil else { return }
            
            // You can modify properties of the duplicated asset if needed,
            // for example, updating metadata, location, etc.
            
            // Perform additional changes if necessary
            
        } completionHandler: { success, error in
            if success {
                // Handle successful duplication
            } else if let error = error {
                print("Error duplicating photo: \(error.localizedDescription)")
            }
        }
    }
    func addAssetToAlbum(asset: PHAsset, album: PHAssetCollection) {
    PHPhotoLibrary.shared().performChanges {
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
        albumChangeRequest?.addAssets([asset] as NSFastEnumeration)
    } completionHandler: { success, error in
        if success {
            // Handle successful addition to album
        } else if let error = error {
            print("Error adding photo to album: \(error.localizedDescription)")
        }
    }
}
    func saveImageToAssetCollection(image: [UIImage], toAlbum album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges {
            for image in image{
                  if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    albumChangeRequest.addAssets([image] as NSFastEnumeration)
                     
                }
            }
        } completionHandler: { success, error in
            if let error = error {
                print("Error saving image to album: \(error)")
            } else {
                print("Image saved to album successfully.")
            }
        }
    }

        





}
