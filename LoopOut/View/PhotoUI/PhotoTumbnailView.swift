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
                    .frame(width: 115, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
        }
    }
    private func fetchImage() -> UIImage {
            var image = UIImage()
            let semaphore = DispatchSemaphore(value: 0)
            
            photoLibraryService.fetchImage(byLocalIdentifier: photo.localIdentifier, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill) { fetchedImage in
                if let fetchedImage = fetchedImage {
                    image = fetchedImage
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return image
        }
}
