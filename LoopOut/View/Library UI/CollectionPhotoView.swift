//
//  CollectionPhotoView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/28.
//

import Foundation
import SwiftUI
import Photos

struct CollectionPhotosView: View {
    var collection: PHAssetCollection
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    var body: some View {
        NavigationStack {
                ScrollView(showsIndicators: false){
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section{
                            if let results = albumCollectionLibraryService.results{
                                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3),spacing: 8) {
                                    ForEach(0..<results.count, id: \.self) { photo in
                                        if let asset = results.object(at: photo) as? PHAsset {
                                            NavigationLink {
                                                PhotoPreview( photo: asset)
                                            } label: {
                                                PhotoTumbnailView(photo: asset)
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
