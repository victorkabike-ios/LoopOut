//
//  PhotoDataDisplayView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/29.
//

import Foundation
import SwiftUI
import Photos
import PhotosUI
import CryptoKit



struct PhotoDataDisplayView: View {
    let albumName: String
    var photoSet: Set<HiddenPhotos> // replace PhotoType with the actual type of your photo
    var photos: [HiddenPhotos] { Array(photoSet) }
    let coreDataManager = CoreDataManager.shared
    let imageEncryption = ImageEncryption()
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                // When you need to decrypt data
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 3),spacing: 0) {
                    ForEach(photos, id: \.self){ photo in
                        if let imageData = photo.imageData, let image = decryptingImage(photoData: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 129, height: 150)
                                .clipped()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    VStack{
                        Button(action: {dismissAction()}) {
                            Image(systemName: "chevron.left")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color.white)
                                .fontWeight(.semibold)
                                .font(.headline)
                            
                            
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(albumName)
                        .font(.custom("netflixsans-black", size: 20))
                        .foregroundColor(Color.white)
                        .fontWeight(.heavy)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15){
//                        Button(action: {}) {
//                            Text("Pro")
//                                .font(.custom("NetflixSans-Bold", size: 16))
//                                .foregroundColor(.white)
//                                .padding(.vertical, 6)
//                                .padding(.horizontal,8)
//                                .bold()
//                                .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
//
//                                .clipShape(Capsule())
//                        }
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .font(.headline)
                        }

                    }
                }
            }
            .foregroundStyle(Color.gray.opacity(0.1))
            .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
            .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
        }
    }
    func decryptingImage(photoData:Data) -> UIImage?{
        var decryptedImage = UIImage()
            if let storedKey = coreDataManager.retrieveEncryptionKey() {
                if let decryptedImageData = imageEncryption.decryptData(photoData, using: storedKey) {
                    // Use the decrypted image data for further processing
                    decryptedImage = UIImage(data: decryptedImageData)!
                    // ... Continue with your logic
                } else {
                    print("Unable to decrypt image data.")
                }
            } else {
                print("Unable to retrieve encryption key.")
            }
        return decryptedImage
    }
}
