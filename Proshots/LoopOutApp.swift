//
//  LoopOutApp.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/09.
//

import SwiftUI
import PhotosUI
import Photos

@main
struct LoopOutApp: App {
    let photoLibraryService = PhotoLibraryService()
    let assetCollectionLibraryService =  CollectionLibraryService()
    var body: some Scene {
        WindowGroup {
            ViewController()
                .environmentObject(photoLibraryService)
                .environmentObject(assetCollectionLibraryService)
                .preferredColorScheme(.dark)
        }
    }
}
