//
//  PhotoLockerViewModel.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/21.
//

import Foundation
import Photos

class PhotoLockerServices: ObservableObject {
    private let albumName = "Hidden Album"
    
    func createHiddenAlbum(completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            // Album already exists
            completion(.success(()))
        } else {
            // Create new album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            }, completionHandler: { success, error in
                if success {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(error))
                }
            })
        }
    }
    func fetchHiddenPhotos(completion: @escaping (Result<[PHAsset], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
            let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            guard let album = collection.firstObject else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Album not found"])))
                }
                return
            }

            let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
            var assets: [PHAsset] = []
            assetsFetchResult.enumerateObjects { (asset, _, _) in
                assets.append(asset)
            }

            DispatchQueue.main.async {
                completion(.success(assets))
            }
        }
    }
}

