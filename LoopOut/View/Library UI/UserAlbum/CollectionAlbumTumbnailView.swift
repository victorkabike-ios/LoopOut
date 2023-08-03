//
//  CollectionAlbumTumbnailView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/29.
//

import Foundation
import Photos
import SwiftUI
import PhotosUI

struct CollectionTumbnailView: View {
    @EnvironmentObject var albumCollectionLibraryService: CollectionLibraryService
    @ObservedObject var photoLibraryService = PhotoLibraryService()
    var collection : PHAssetCollection
    @State private var photo:PHAsset?
    var body: some View {
        VStack(alignment: .leading){
            ZStack{
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color.gray.opacity(0.1))
                if photo != nil {
                    Image(uiImage: fetchImage() )
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "sparkles.rectangle.stack")
                        .foregroundStyle(Color.gray.opacity(0.2))
                        .font(.largeTitle)
                }
            }
            VStack(alignment: .leading){
                Text(collection.localizedTitle ?? "")
                    .foregroundColor(Color.white)
                    .font(.custom("netflixsans-Regular", size: 12))
                Text("\(collection.estimatedAssetCount) items")
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .font(.caption)
            }
            
        }
        .frame(width: 185, height: 250)
        .background(Color.blue.opacity(0.15))
        .cornerRadius(15)
        .onAppear{
            albumCollectionLibraryService.fetchAllPhotos(collection: collection)
            if let results = albumCollectionLibraryService.results{
                if results != nil{
                    photo = results.firstObject
                }
            }
            
        }
    }
    
    private func fetchImage() -> UIImage {
            var image = UIImage()
            let semaphore = DispatchSemaphore(value: 0)
        if photo != nil {
            photoLibraryService.fetchImage(byLocalIdentifier: photo!.localIdentifier   , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill) { fetchedImage in
                    if let fetchedImage = fetchedImage {
                        image = fetchedImage
                    }
                    semaphore.signal()
                }
        }
            
            semaphore.wait()
            return image
        }
}
