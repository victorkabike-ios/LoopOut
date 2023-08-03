//
//  MediaCategoryView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI

enum MediaCategory: String , CaseIterable {
    case sefies = "Selfies"
    case livePhotos = "Live Photos"
    case screenshots = "Screenshots"
    case portrait = "Portraits"
    
    var icons: Image {
        switch self {
        case .sefies:
           return Image(systemName: "face.dashed")
        case .livePhotos:
            return Image(systemName: "livephoto")
        case .screenshots:
           return Image(systemName: "camera.viewfinder")
        case .portrait:
            return Image(systemName: "person.fill.viewfinder")
        }
        
    }
}

struct MediaCategoryTumbnailView: View {
    var  title: String
    var icon: Image
    var body: some View {
        ZStack{
            HStack{
                icon
                    .resizable()
                    .foregroundColor(Color.blue)
                    .frame(width: 25, height: 25)
                Text(title)
                    .foregroundColor(Color.white)
                    .font(.custom("netflixsans-Bold", size: 14))
                Spacer()
            }
            .padding(.leading)
            .frame(width: 180, height: 60)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct MediaPhotoPreview: View {
    @EnvironmentObject var mediaLibraryService: MediaLibraryService
    var body: some View {
        ZStack{
            ScrollView(showsIndicators: false){
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section{
                        if let results = mediaLibraryService.results{
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
        }
    }
}

struct MediaCategoryView: View {
   
    @EnvironmentObject var mediaLibraryService: MediaLibraryService
    var body: some View {
        ZStack{
            VStack(spacing: 18){
                HStack {
                    Text("Category")
                        .font(.custom("netflixsans-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8) {
                        ForEach(MediaCategory.allCases, id: \.hashValue){ category in
                            NavigationLink {
                                MediaPhotoPreview()
                                    .environmentObject(mediaLibraryService)
                                    .onAppear {
                                        mediaLibraryService.requestAuthorization(category: category)
                                    }
                            } label: {
                                MediaCategoryTumbnailView(title: category.rawValue, icon: category.icons)
                            }
                            
                            
                        }
                    }
                }
                }.frame(maxHeight: .infinity, alignment: .top)
            }
        
        }
    }


