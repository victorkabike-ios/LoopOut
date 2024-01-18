//
//  SimilarPHLibraryHelper.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/12.
//

import Foundation
import Photos
import UIKit

class SimilarPHLibraryHelper: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var results: PHFetchResult<PHAsset>?
    @Published var photoCategories: [String: [UIImage]] = [:]
    @Published var isScanning:Bool = false
    var imageCachingManager = PHCachingImageManager()
    
    func requestAuthorization(category: MediaCategory,handleError: ((AuthorizationError?) -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                switch status {
                case .authorized:
                    switch category {
                    case .livePhotos:
                        self?.fetchLivePhotos()
                    case .screenshots:
                        self?.fetchScreenshots()
                    case .photos:
                        self?.fetchPhotosPhotos()
                    }
                case .denied, .restricted:
                    handleError?(.restrictedAccess)
                case .notDetermined:
                    break
               
                @unknown default:
                    break
                }
            }
        }
    }
    func fetchLivePhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(
                           format: "(mediaSubtype & %d) != 0",
                           PHAssetMediaSubtype.photoLive.rawValue
                       )
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchScreenshots() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(
                           format: "(mediaSubtype & %d) != 0",
                           PHAssetMediaSubtype.photoScreenshot.rawValue
                       )
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchPhotosPhotos() {
        isScanning = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(
                format: "mediaType = %d AND NOT ((mediaSubtype & %d) != 0 OR (mediaSubtype & %d) != 0)",
                PHAssetMediaType.image.rawValue,
                PHAssetMediaSubtype.photoLive.rawValue,
                PHAssetMediaSubtype.photoScreenshot.rawValue
            )
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
        // Replace with your actual fetch result
        if let fetchResult = results{
            
            for index in 0..<fetchResult.count {
                let asset = fetchResult.object(at: index)
                let image =  fetchImagefunction(image: asset) // Implement this function
                
                if let category = SimilarPhotoCategorizationHelper.category(for: image) {
                    if photoCategories[category] == nil {
                        photoCategories[category] = []
                    }
                    photoCategories[category]?.append(image)
                }
            }
            isScanning = false
        }
    }
    func fetchImage(byLocalIdentifier localIdentifier: String, targetSize: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage?) -> Void) {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject else {
            completion(nil)
            return
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        imageCachingManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: requestOptions) { image, _ in
            completion(image)
        }
    }
    private func fetchImagefunction(image:PHAsset) -> UIImage {
         let semaphore = DispatchSemaphore(value: 0)
         var selectedPhoto = UIImage()
         fetchImage(byLocalIdentifier: image.localIdentifier, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill) { fetchedImage in
             if let fetchedImage = fetchedImage {
                 selectedPhoto = fetchedImage
             }
             semaphore.signal()
         }
         
         semaphore.wait()
         return selectedPhoto
     }
    
}
