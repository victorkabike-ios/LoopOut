//
//  SmartAlbumView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI


struct SmartAlbumView:View {
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    var body: some View {
        ZStack{
            VStack(spacing: 18){
                HStack {
                    Text("Shared Albums")
                        .font(.custom("netflixsans-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: Array(repeating: .init(.flexible(), spacing: 8), count: 1),spacing: 8) {
                        ForEach(SharedAlbum.allCases, id: \.hashValue){ album in
                            SharedAlbumTumbnailView(title: album.rawValue, image: album.icon)
                        }
                    }.frame(height: 150)
                }.frame(maxHeight: .infinity, alignment: .top)
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        }
    }
}
