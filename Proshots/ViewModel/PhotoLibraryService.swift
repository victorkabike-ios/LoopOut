//import Foundation
import Photos
import UIKit
enum AuthorizationError: Error {
    case restrictedAccess
    case deniedAccess
}
class PhotoLibraryService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var results: PHFetchResult<PHAsset>?
    @Published var hiddenResults: PHFetchResult<PHAsset>?
    var imageCachingManager = PHCachingImageManager()
    
    func requestAuthorization(handleError: ((AuthorizationError?) -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                
                switch status {
                case .authorized:
                    self?.fetchAllPhotos()
                    self?.fetchHiddenPhotos()
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
     func fetchAllPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        results = fetchResult
        
        imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    func fetchHiddenPhotos() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.includeHiddenAssets = true // changed from false to true
            fetchOptions.predicate = NSPredicate(format: "isHidden == YES")
//            fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue), NSPredicate(format: "isHidden == %d", 1)]) // added another predicate to filter out non-hidden photos
            
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            hiddenResults = fetchResult
            
            imageCachingManager.startCachingImages(for: fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count)), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
        }
/*
 function that first asks for user permission before deleting the PHAsset:
 */
    func requestAndDeletePhoto(asset: PHAsset, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges({
                    self.performDelete(for: asset, completion: completion)
                })
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [self] status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            self.performDelete(for: asset, completion: completion)
                        })
                    } else {
                        completion(false, nil)
                    }
                }
            default:
                completion(false, nil)
            }
        }
    }

     func performDelete(for asset: PHAsset, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
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
}
