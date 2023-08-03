//
//  SmartAlbumTumbnailView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//
import Foundation
import Photos
import SwiftUI
import PhotosUI

struct SharedAlbumTumbnailView : View {
    var title: String
    var image: Image
    var body: some View {
        VStack(alignment:.leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 120, height: 120)
                    .foregroundStyle(Color.blue.opacity(0.1))
                
                image
                    .foregroundStyle(Color.blue)
                    .font(.largeTitle)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Color.white)
                    .font(.custom("netflixsans-Regular", size: 12))
                
                Text("")
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .font(.caption)
            }
        }
    }
}
