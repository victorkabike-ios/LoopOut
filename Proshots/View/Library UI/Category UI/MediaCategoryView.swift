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
    case livePhotos = "Live Photos"
    case screenshots = "Screenshots"
    case photos = "Photos"
    
    var icons: Image {
        switch self {
        case .livePhotos:
            return Image(systemName: "livephoto")
        case .screenshots:
           return Image(systemName: "camera.viewfinder")
        case .photos:
            return Image(systemName: "person.fill.viewfinder")
        }
        
    }
}






