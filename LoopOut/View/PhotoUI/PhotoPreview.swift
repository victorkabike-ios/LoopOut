//
//  PhotoPreview.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/15.
//

import Photos
import SwiftUI
import CoreML
import CoreMedia
import Vision
import CoreImage
import BrightroomUI
import BrightroomEngine

struct PhotoPreview:View {
    @ObservedObject var PhotoController = CorePhotoController()
    @EnvironmentObject var  photoLibraryService: PhotoLibraryService
    var photo: PHAsset
    @State var processedImage = UIImage()
    @State var resizedImage = UIImage()
    @State var addFavorites: Bool = false
    
    @State private var showCropEditor: Bool = false
    @State private var selectedRect: CGRect?
    var body: some View {
        NavigationStack{
                VStack(spacing: 20){
                    ZStack(alignment: .top){
                        Image(uiImage: processedImage)
                            .resizable()
                            .clipped()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 380 , height: 500 )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .background(Color.clear)
                        
                        
                        
                        
                    }
                    .frame(width: 380 , height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack(spacing: 30){
                            HStack(alignment: .center, spacing: 25){
                                ButtonView(imageName: "square.and.arrow.up", buttonText: "Share") {
                                    PhotoController.shareImage(image: processedImage)
                                }
                                ButtonView(imageName:  "square.and.pencil", buttonText: "Edit"){
                                    
                                }
                                ButtonView(imageName: addFavorites ?  "heart.fill" : "heart", buttonText: "Like") {
                                    PhotoController.addImageToFavorites(asset: photo)
                                    addFavorites.toggle()
                                }
                                ButtonView(imageName: "rectangle.stack.badge.plus", buttonText: "Add to Album") {
                                    
                                }
                                
                                ButtonView(imageName: "trash.fill", buttonText: "delete") {
                                   
                                }
                            }
                        
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal,0)
                    .onAppear{
                        processedImage = fetchImage()
                        resizedImage = fetchImage()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                            } label: {
                                Text("Save")
                                    .foregroundColor(.white)
                                    .padding(.vertical,8)
                                    .padding(.horizontal,12)
                                    .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(Capsule())
                            }
                            

                        }
                    }
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
                    .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
                    
            
        }
      
    }
    private func fetchImage() -> UIImage {
         var image = UIImage()
         let semaphore = DispatchSemaphore(value: 0)
         
         photoLibraryService.fetchImage(byLocalIdentifier: photo.localIdentifier, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill) { fetchedImage in
             if let fetchedImage = fetchedImage {
                 image = fetchedImage
             }
             semaphore.signal()
         }
         
         semaphore.wait()
         return image
     }
    
}



