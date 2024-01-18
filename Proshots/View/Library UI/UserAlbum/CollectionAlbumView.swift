//
//  CollectionAlbumView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI
struct AlbumCollectionView:View {
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    var albumCollections : [PHAssetCollection]
    @State var newAlbumView: Bool = false
    @Binding var emptyCollectionsCount: Int
  
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                    VStack(spacing: 18){
                        VStack(alignment: .leading, spacing: 20){
//                            HStack {
//                                Text("My Album")
//                                    .font(.custom("NetflixSans-Bold", size: 28))
//                                    .foregroundColor(.white)
//
//                                Spacer()
//
//                            }
                            
                            HStack(alignment: .center,spacing: 18){
                                Image(systemName: "paintbrush.fill")
                                    .resizable()
                                    .frame(width: 30,height: 30)
                                    .foregroundColor(.white)
                                VStack(alignment: .leading){
                                    Text("Empty Album")
                                        .font(.custom("NetflixSans-Bold", size: 18))
                                        .foregroundColor(.white)
                                    Text("\(emptyCollectionsCount)")
                                        .font(.custom("NetflixSans-Bold", size: 14))
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Button {
                                    let emptyCollections = getEmptyCollections(albumCollections: albumCollections)
                                        for collection in emptyCollections {
                                            deleteEmptyCollection(collection)
                                        }
                                } label: {

                                    Text("Clean up")
                                        .foregroundColor(.white)
                                        .font(.custom("NetflixSans-Bold", size: 16))
                                        .frame(width: 90, height: 40)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                }

                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        

                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8){
                                ForEach(getNonEmptyCollections(albumCollections: albumCollections), id: \.localIdentifier) { collection in
                                    NavigationLink {
                                        CollectionPhotosView(collection: collection)
                                            .environmentObject(albumCollectionLibraryService)
                                            
                                    } label: {
                                        CollectionTumbnailView(collection: collection)
                                            .environmentObject(albumCollectionLibraryService)
                                       
                                    }
                                }
                            }
                         
                        }.frame(maxHeight: .infinity, alignment: .top)
                    }
                    
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    func filterCollections(albumCollections: [PHAssetCollection], predicate: (Int) -> Bool) -> [PHAssetCollection] {
        return albumCollections.filter { collection in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            return predicate(assets.count)
        }
    }

    func getNonEmptyCollections(albumCollections: [PHAssetCollection]) -> [PHAssetCollection] {
        return filterCollections(albumCollections: albumCollections, predicate: { $0 > 0 })
    }

    func getEmptyCollections(albumCollections: [PHAssetCollection]) -> [PHAssetCollection] {
        return filterCollections(albumCollections: albumCollections, predicate: { $0 == 0 })
    }
    func deleteEmptyCollection(_ collection: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections([collection] as NSArray)
        }, completionHandler: { success, error in
            if success {
                // The collection was successfully deleted
                print("Successfully deleted empty collection.")
                // Optionally, you can also update your data source and UI to reflect the change.
            } else if let error = error {
                // An error occurred
                print("Error deleting collection: \(error)")
            } else {
                // The operation didn't succeed, and no error was given
                print("Could not delete collection for an unknown reason.")
            }
        })
    }
}


