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
    case cleanup = "Clean up"
    case Resizer = "Photo Resizer"
    case lockPhotos = "lock  Photos"
    var icon :Image {
        switch self {
        case .cleanup:
            return Image(systemName: "paintbrush")
        case .Resizer:
            return Image(systemName: "crop")
        case .lockPhotos:
            return Image(systemName: "lock")
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
        }
    }
    
  
}

struct UtilitiesView: View {
    var body: some View {
        NavigationStack{
            ZStack {
                ScrollView{
                    LazyVStack{
                        ForEach(Phototools.allCases, id: \.rawValue){ tool in
                            UtilityButtonView(title: tool.rawValue, icon: tool.icon, thumbnail: tool.thumbnail) {
                                
                            }
                            .padding(12)
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


struct UtilityButtonView<Content: View>: View {
    let content: Content
    let title: String
    let icon : Image
    let thumbnail: Image
    
    init(title: String,icon:Image, thumbnail: Image, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.thumbnail = thumbnail
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Label {
                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("netflixsans-Bold", size: 18))
            } icon: {
                icon
                    .foregroundColor(.white)
            }

            ZStack(alignment: .center){
                thumbnail
                    .clipped()
                    .frame(width: 340, height: 240)
                    .aspectRatio( contentMode: .fit)
                    .cornerRadius(10)
            }
            .padding()
            .background(Color.blue.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
                
            content
        }
      
      
    }
}


