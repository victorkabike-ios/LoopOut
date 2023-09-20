//
//  LockPhotoDisplayView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/20.
//

import Foundation
import SwiftUI

struct LockPhotoViewController: View {
    @ObservedObject var securityController: SecurityController
    @State private var showPhotos = false

    var body: some View {
        VStack {
            if showPhotos {
                // Display your photos here
               HiddenAlbumView()
            } else {
                Button("Unlock Photos") {
                    securityController.authenticateWithFaceID { success in
                        if success {
                            showPhotos = true
                        } else {
                            // Show an error message
                        }
                    }
                }
            }
        }
    }
}
