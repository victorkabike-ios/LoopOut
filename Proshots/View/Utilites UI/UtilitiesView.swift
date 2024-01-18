//
//  UtilitiesView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/03.
//

import Foundation
import SwiftUI
import Photos
enum Phototools : String, CaseIterable {
    case cleanup = "Clean Photos"
    case Resizer = "Photo Resizer"
    case lockPhotos = "lock  Photos"
    case college = "Photo College"
    var icon :Image {
        switch self {
        case .cleanup:
            return Image(systemName: "paintbrush")
        case .Resizer:
            return Image(systemName: "crop")
        case .lockPhotos:
            return Image(systemName: "lock")
        case .college:
            return Image(systemName: "square.grid.2x2")
        }
    }
    var thumbnail: Image {
        switch self {
        case .cleanup:
            return Image("cleanup")
        case .Resizer:
            return Image("photoresize")
        case .lockPhotos:
            return Image("lockphoto")
        case .college:
            return Image("college")
        }
    }
    
    var view: some View {
        switch self {
        case .cleanup:
            return AnyView(SimilarPhotoController())
        case .Resizer:
            return AnyView(ResizerView())
        case .lockPhotos:
            return AnyView(LockPhotoView())
        case .college:
            return AnyView(collegeView())
        }
    }

  
}

struct UtilitiesView: View {
    @State private var showNavigationBar = true
    var body: some View {
        NavigationStack{
            ZStack {
                ScrollView(.vertical, showsIndicators: false){
                    LazyVStack{
                        Section{
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8) {
                                ForEach(Phototools.allCases, id: \.rawValue){ tool in
                                    NavigationLink {
                                        tool.view
                                            .navigationBarBackButtonHidden(true)
                                            .toolbar(.hidden, for: .tabBar)
                                            
                                    } label: {
                                        UtilityButtonView(title: tool.rawValue,thumbnail: tool.thumbnail)
                                           
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    VStack{
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color.white)
                                .fontWeight(.semibold)
                                .font(.headline)
                            
                            
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Utility")
                        .font(.custom("netflixsans-black", size: 20))
                        .foregroundColor(Color.white)
                        .fontWeight(.heavy)
                }
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
                        
                    }
                }
            }
            .foregroundStyle(Color.gray.opacity(0.1))
            .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
            .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
        }
    }
}


struct UtilityButtonView: View {
    let title: String
    let thumbnail: Image
    
    init(title: String, thumbnail: Image) {
        self.title = title
        self.thumbnail = thumbnail
    }
    
    var body: some View {
        ZStack(alignment:.top){
            RoundedRectangle(cornerRadius: 18)
                .frame(width: 180, height: 300)
                .foregroundStyle(.gray.opacity(0.2))
            VStack(spacing: 20){
                thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 250)
                    .clipped()
                Text(title)
                    .font(.custom("netflixsans-black", size: 16))
                    .foregroundColor(.white)
            }
         
                
            }
                
        
      
      
    }
}


