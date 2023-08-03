//
//  CollectionLibraryServices.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/27.
//

import Foundation
import Photos
import SwiftUI


enum AlbumCreationError: Error {
    case failedToCreate
    case albumAlreadyExists
}

class CollectionLibraryService: ObservableObject {
    @Published var collections: [PHAssetCollection] = []
    @Published var results: PHFetchResult<PHAsset>?
    
    var imageCachingManager = PHCachingImageManager()
    func fetchAlbums(completion: @escaping ([PHAssetCollection]) -> Void) {
        let fetchOptions = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        userAlbums.enumerateObjects { (collection, _, _) in
            self.collections.append(collection)
        }
        
        completion(collections)
    }
    func fetchAllPhotos(collection: PHAssetCollection) {
       let fetchOptions = PHFetchOptions()
       fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
       fetchOptions.includeHiddenAssets = false
       fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
       results = fetchResult
       
       imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
   }


    func fetchAssetCollection(withTitle albumTitle: String, completion: @escaping (PHAssetCollection?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let albumCollection = collections.firstObject {
            completion(albumCollection)
        } else {
            completion(nil)
        }
    }

    func fetchAssetsFromAlbum(withTitle albumTitle: String, completion: @escaping ([PHAsset]) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let assetCollection = album.firstObject, let assets = PHAsset.fetchAssets(in: assetCollection, options: nil) as? PHFetchResult<PHAsset> {
            var assetArray: [PHAsset] = []
            assets.enumerateObjects { asset, _, _ in
                assetArray.append(asset)
            }
            completion(assetArray)
        } else {
            completion([])
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

    func createAlbum(withTitle albumTitle: String, completion: @escaping (Result<Void, AlbumCreationError>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        
        DispatchQueue.global(qos: .default).async {
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                // Create new album
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                }, completionHandler: { success, error in
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(.failedToCreate))
                        if let error = error {
                            print("Error creating album: \(error)")
                        }
                    }
                })
        }
    }
    func addImages(_ images: [UIImage], toAlbumWithTitle albumTitle: String, completion: @escaping (Bool, Error?) -> Void) {
        var albumPlaceholder: PHObjectPlaceholder?
        
        // Request access to the Photos library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                // Handle the case when access is not granted
                completion(false, NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access to Photos library not granted."]))
                return
            }
            
            // Fetch the album with the specified title
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
            let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            // Create the image request
            PHPhotoLibrary.shared().performChanges({
                // Create a request to add the images to the album
                let albumChangeRequest: PHAssetCollectionChangeRequest?
                if let album = album.firstObject {
                    albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                } else {
                    albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                    albumPlaceholder = albumChangeRequest?.placeholderForCreatedAssetCollection
                }
                
                if let albumChangeRequest = albumChangeRequest, let albumPlaceholder = albumPlaceholder {
                    // Add the images to the album
                    var assets: [PHObjectPlaceholder] = []
                    for image in images {
                        let imageChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        let assetPlaceholder = imageChangeRequest.placeholderForCreatedAsset
                        assets.append(assetPlaceholder!)
                    }
                    albumChangeRequest.addAssets(assets as NSArray)
                }
            }, completionHandler: { success, error in
                // Handle the completion of the request
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            })
        }
    }


}
