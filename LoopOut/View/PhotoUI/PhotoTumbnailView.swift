//
//  PhotoTumbnailView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/14.
//

import Foundation
import SwiftUI
import Photos

struct PhotoTumbnailView: View {
    @ObservedObject var photoLibraryService = PhotoLibraryService()
    var photo: PHAsset
    @State var isSelected: Bool = false
    var body: some View {
        ZStack(alignment: Alignment.topTrailing){
          
            Image(uiImage:fetchImage())
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 129, height: 130)
                    .clipped()                
        }
    }
    private func fetchImage() -> UIImage {
            var image = UIImage()
            let semaphore = DispatchSemaphore(value: 0)
            
            photoLibraryService.fetchImage(byLocalIdentifier: photo.localIdentifier, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill) { fetchedImage in
                if let fetchedImage = fetchedImage {
                    image = fetchedImage
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return image
        }
}
