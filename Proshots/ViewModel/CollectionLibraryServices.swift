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
    func addImagesToAssetCollection(images: [UIImage], assetCollection: PHAssetCollection) {
            // Request authorization to access the Photos library
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("Access to Photos library is not authorized.")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges {
                    // Create a PHAssetChangeRequest for each image and add them to the collection
                    let options = PHAssetResourceCreationOptions()
                    var placeholderAssets: [PHObjectPlaceholder] = []
                    
                    for image in images {
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            let creationRequest = PHAssetCreationRequest.forAsset()
                            let creationOptions = PHAssetResourceCreationOptions()
                            creationOptions.shouldMoveFile = true
                            
                            creationRequest.addResource(with: .photo, data: imageData, options: creationOptions)
                            
                            if let placeholder = creationRequest.placeholderForCreatedAsset {
                                placeholderAssets.append(placeholder)
                            }
                        }
                    }
                    
                    // Fetch the newly created assets and add them to the collection
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(format: "SELF IN %@", placeholderAssets)
                    let fetchedAssets = PHAsset.fetchAssets(with: fetchOptions)
                    
                    if let collectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                        collectionChangeRequest.addAssets(fetchedAssets)
                    }
                } completionHandler: { success, error in
                    if success {
                        print("Images added to asset collection successfully.")
                    } else if let error = error {
                        print("Error adding images to asset collection: \(error.localizedDescription)")
                    }
                }
            }
        }


}
