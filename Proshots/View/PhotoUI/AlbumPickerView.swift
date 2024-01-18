//
//  AlbumPickerView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/09.
//

import Foundation
import SwiftUI
import Photos

struct ListAlbumsView: View {
    @Binding var selectedAsset: PHAsset?
    @Binding var isPresented: Bool
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    var albumCollections : [PHAssetCollection]
    @ObservedObject var corePhotoController = CorePhotoController()
    var nonEmptyCollections: [PHAssetCollection] {
        albumCollections.filter { collection in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            return assets.count > 0
        }
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVStack{
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8) {
                        ForEach(nonEmptyCollections, id: \.localIdentifier) { album in
                            Button(action: {
                                corePhotoController.addAssetToAlbum(asset: selectedAsset!, album: album)
                                isPresented = false
                            }) {
                                CollectionTumbnailView(collection: album)
                            }
                        }
                    }
                }
            }
        }
            
    }
    

}




