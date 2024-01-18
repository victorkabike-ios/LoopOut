//
//  SimilarPhotoView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/12.
//

import Foundation
import SwiftUI
import Photos
import Vision

struct SimilarPhotoController: View {
    @State private var photoCategories: [String: [UIImage]] = [:]
    @ObservedObject var similarPHLibraryHelper = SimilarPHLibraryHelper()
    @Environment(\.dismiss) var dismissAction
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    Spacer()
                    if similarPHLibraryHelper.isScanning{
                        ProgressView {
                            Text("Searching for Similar Photos")
                        }.progressViewStyle(CircularProgressViewStyle())
                    }
                    Spacer()
                    NavigationLink {
                        SimilarPhotoView(photoCategories: similarPHLibraryHelper.photoCategories)
                    } label: {
                        Text("Free Up")
                            .font(.custom("NetflixSans-Bold", size: 18))
                            .foregroundColor(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 18)
                                    .frame(width: 340, height: 60)
                                    .foregroundColor(Color.blue)
                            }
                        
                    }
                }.padding()
              
            }
            .onAppear(perform: {
                similarPHLibraryHelper.requestAuthorization(category: .photos)
//                // Replace with your actual fetch result
//                if let fetchResult = similarPHLibraryHelper.results{
//
//                    for index in 0..<fetchResult.count {
//                        let asset = fetchResult.object(at: index)
//                        let image = fetchImage(image: asset) // Implement this function
//
//                        if let category = SimilarPhotoCategorizationHelper.category(for: image) {
//                            if photoCategories[category] == nil {
//                                photoCategories[category] = []
//                            }
//                            photoCategories[category]?.append(image)
//                        }
//                    }
//                }
            })
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
    private func fetchImage(image:PHAsset) -> UIImage {
         let semaphore = DispatchSemaphore(value: 0)
         var selectedPhoto = UIImage()
         similarPHLibraryHelper.fetchImage(byLocalIdentifier: image.localIdentifier, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill) { fetchedImage in
             if let fetchedImage = fetchedImage {
                 selectedPhoto = fetchedImage
             }
             semaphore.signal()
         }
         
         semaphore.wait()
         return selectedPhoto
     }
}

struct SimilarPhotoView: View {
     var photoCategories: [String: [UIImage]]
    @ObservedObject var similarPHLibraryHelper = SimilarPHLibraryHelper()
    @State var selecteditem:[UIImage] = []

    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVStack{
                    ForEach(photoCategories.keys.sorted().filter { photoCategories[$0]!.count > 1 }, id: \.self) { category in
                        Section{
                            ScrollView(.horizontal, showsIndicators: false){
                                LazyHStack(spacing: 8){
                                    ForEach(photoCategories[category]!, id: \.self) { image in
                                        ZStack(alignment: .bottomLeading){
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
                                                .frame(width: 180,height: 200)
                                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                            HStack{
                                                // Add a label to the first photo of each category
                                                if photoCategories[category]!.first == image {
                                                    HStack{
                                                        Image(systemName: "heart.fill")
                                                            .font(.caption)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                        Text("Best Photo")
                                                            .font(.caption2)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.white)
                                                    }
                                                    .frame(width: 100, height: 30)
                                                    .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                                                    .clipShape(Capsule())
                                                } else {
                                                    HStack{
                                                        Spacer()
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .symbolRenderingMode(.palette)
                                                            .resizable()
                                                            .foregroundStyle(.white, .red)
                                                            .frame(width: 30, height: 30)
                                                            .bold()
                                                        
                                                    }
                                                    
                                                }
                                                Spacer()
                                                
                                            }.padding(8)
                                            
                                        }
                                        
                                    }
                                }
                            }
                          } header: {
                            HStack{
                                Text("Similar Photo (\(photoCategories[category]!.count))")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                    
                }.padding(.leading)
            }
            .navigationTitle("Similar Photos")
            .navigationBarTitleDisplayMode(.large)
            
        }
      
    }
    
}


