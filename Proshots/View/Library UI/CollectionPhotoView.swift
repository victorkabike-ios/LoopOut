//
//  CollectionPhotoView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/28.
//

import Foundation
import SwiftUI
import Photos
import PhotosUI

struct CollectionPhotosView: View {
    var collection: PHAssetCollection
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    @ObservedObject  var CoreAction = CorePhotoController()
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State var photoAssets: [PHAsset] = []
    // Function to convert PHFetchResult to an array
    private func convertFetchResultToArray(fetchResult: PHFetchResult<PHAsset>) {
           for index in 0..<fetchResult.count {
               let asset = fetchResult.object(at: index)
               photoAssets.append(asset)
           }
       }
    var body: some View {
        NavigationStack {
                ScrollView(showsIndicators: false){
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section{
                            if let results = albumCollectionLibraryService.results{
                                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3),spacing: 8) {
                                    PhotosPicker(selection: $selectedItems, matching: .images,photoLibrary: .shared()) {
                                        ZStack{
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(.blue)
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 120 , height: 150)
                                                .foregroundStyle(Color.gray.opacity(0.1))
                                        }
                                    }
                                    ForEach(0..<results.count, id: \.self) { photo in
                                        if let asset = results.object(at: photo) as? PHAsset {
                                            NavigationLink {
                                                PhotoPreview( photo: asset, photoAssets: photoAssets)
                                                    .onAppear{convertFetchResultToArray(fetchResult: results)}
                                                    .toolbar(.hidden, for: .tabBar)
                                                    .navigationBarBackButtonHidden()
                                                
                                            } label: {
                                                PhotoTumbnailView(photo: asset)
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }
                                .onChange(of: selectedItems) { newItem in
                                    Task {
                                        selectedImages.removeAll()
                                        
                                        for item in selectedItems {
                                            if let identifier = try? await item.itemIdentifier {
                                                // Fetch the asset using the identifier
                                                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
                                                if let asset = assets.firstObject {
                                                    // Add the asset to the album
                                                    PHPhotoLibrary.shared().performChanges({
                                                        // Create a change request for the album
                                                        let changeRequest = PHAssetCollectionChangeRequest(for: collection)
                                                        
                                                        // Add the asset to the album
                                                        changeRequest?.addAssets([asset] as NSArray)
                                                    }, completionHandler: { success, error in
                                                        if success {
                                                            // Asset added successfully
                                                            DispatchQueue.main.async {
                                                                albumCollectionLibraryService.fetchAllPhotos(collection: collection)
                                                            }
                                                            
                                                        } else {
                                                            // Handle error
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    }
                                }


                            }
                        }
                    }
                }
                .onAppear{
                    albumCollectionLibraryService.fetchAllPhotos(collection: collection)
                }
        }
    }
    
}
