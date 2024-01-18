//
//  AlbumsView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/27.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI

struct LibraryView: View {
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    @EnvironmentObject var mediaLibraryService: MediaLibraryService
    @State var assetCollection: [PHAssetCollection] = []
    @State var emptyCollectionsCount: Int = 0
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                ScrollView(.vertical,showsIndicators: false){
                    LazyVStack(spacing: 20){
                        AlbumCollectionView(albumCollections: assetCollection, emptyCollectionsCount: $emptyCollectionsCount)
                                .padding(.leading)
                                .onAppear{
                                    albumCollectionLibraryService.fetchAlbums { collections in
                                        self.assetCollection = collections
                                    }
                                    // Then count the empty collections
                                                self.emptyCollectionsCount = assetCollection.filter { collection in
                                                    let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                                                    return fetchResult.count == 0
                                                }.count
                                }
                       
                      
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading){
//                    VStack{
//                        Button(action: {}) {
//                            Image(systemName: "chevron.left")
//                                .symbolRenderingMode(.monochrome)
//                                .foregroundStyle(Color.white)
//                                .fontWeight(.semibold)
//                                .font(.headline)
//                            
//                            
//                        }
//                    }
//                }
//                ToolbarItem(placement: .principal) {
//                    Text("Library")
//                        .font(.custom("netflixsans-black", size: 20))
//                        .foregroundColor(Color.white)
//                        .fontWeight(.heavy)
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15){
                        Button(action: {}) {
                            Text("Pro")
                                .font(.custom("NetflixSans-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal,8)
                                .bold()
                                .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                            
                                .clipShape(Capsule())
                        }
//                        Button(action: {}) {
//                            Image(systemName: "plus")
//                                .foregroundColor(.white)
//                                .fontWeight(.semibold)
//                                .font(.headline)
//                        }
                        
                    }
                }
            }
            .foregroundStyle(Color.gray.opacity(0.1))
            .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
            .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
        }
    }
}

