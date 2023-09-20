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

}
