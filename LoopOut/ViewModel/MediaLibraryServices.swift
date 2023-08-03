//
//  MediaLibraryServices.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import UIKit
import ImageIO

class MediaLibraryService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var results: PHFetchResult<PHAsset>?
    var imageCachingManager = PHCachingImageManager()
    var imageRequestOptions = PHImageRequestOptions()
    
    func requestAuthorization(category: MediaCategory,handleError: ((AuthorizationError?) -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                
                switch status {
                case .authorized:
                    switch category {
                    case .sefies:
                        self?.fetchSelfiesPhotos()
                    case .livePhotos:
                        self?.fetchLivePhotos()
                    case .screenshots:
                        self?.fetchScreenshots()
                    case .portrait:
                        self?.fetchPortraitPhotos()
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
    func saveImageToLibrary(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        request.creationDate = Date()
                    } completionHandler: { success, error in
                        completion(success, error)
                    }
                } else {
                    let error = NSError(domain: "com.yourapp.photoLibraryError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
                    completion(false, error)
                }
            }
        }
    func fetchSelfiesPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(
                            format: "NOT ( ( (mediaSubtype & %d) != 0) || ( (mediaSubtype & %d) != 0) || (burstIdentifier != nil))",
                            PHAssetMediaSubtype.photoLive.rawValue,
                            PHAssetMediaSubtype.photoScreenshot.rawValue
                        )
            
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        results = fetchResult
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchLivePhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d && mediaSubtype == %d", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoLive.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchScreenshots() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d && mediaSubtype == %d", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchPortraitPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d AND (mediaSubtype & %d) != 0", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoDepthEffect.rawValue)
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
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
}
