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
    
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                VStack(spacing: 18){
                    VStack(alignment: .leading){
                        HStack {
                            Text("My Album")
                                .font(.custom("netflixsans-Medium", size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                        }
                        
//                        HStack{
////                            Image(systemName: "paintbrush.fill")
////                                .resizable()
////                                .frame(width: 20,height: 20)
////                                .foregroundColor(.white)
//                            VStack(alignment: .leading){
//                                Text("Clean up Empty Album")
//                                    .font(.custom("netflixsans-Medium", size: 16))
//                                    .foregroundColor(.white)
//                                Text("\(EmptyCollections.count)")
//                                    .font(.custom("netflixsans-Regular", size: 12))
//                                    .foregroundColor(.blue)
//                            }
//                            Spacer()
//                            Button {
//
//                            } label: {
//
//                                Text("Clean up")
//                                    .foregroundColor(.white)
//                                    .font(.custom("netflixsans-Medium", size: 12))
//                                    .frame(width: 80, height: 40)
//                                    .background(Color.blue)
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                            }
//
//                        }
//                        .padding()
//                        .background(Color.blue.opacity(0.1))
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }.padding(.horizontal)
                    

                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8){
                            ForEach(nonEmptyCollections, id: \.localIdentifier) { collection in
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
            
        }
    }
    var nonEmptyCollections: [PHAssetCollection] {
        albumCollections.filter { collection in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            return assets.count > 0
        }
    }
    var EmptyCollections: [PHAssetCollection] {
        albumCollections.filter { collection in
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            return assets.count  == 0
        }
    }
}
