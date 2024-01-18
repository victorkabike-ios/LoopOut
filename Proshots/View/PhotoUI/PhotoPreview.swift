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
    @State  var photo: PHAsset
    var photoAssets: [PHAsset] // Your array of PHAsset objects
    @State var processedImage = UIImage()
    @State var resizedImage = UIImage()
    @State var addFavorites: Bool = false
    @State private var showCropEditor: Bool = false
    @State private var showphotoInfo: Bool = false
    @State private var onTapGesture: Bool = false
    @State private var selectedRect: CGRect?
    @State private var isDetailViewPresented = true
    @State private var currentIndex = 0

    @Environment(\.dismiss) var dismissAction
    var body: some View {
        NavigationStack{
            GeometryReader { proxy in
                let frameHeight = max(proxy.size.height - 100, 0)
                        Image(uiImage: processedImage)
                                        .resizable()
                                        .frame(width: proxy.size.width, height:frameHeight)
                                        .frame(alignment: .top)
                                        .scaledToFit()
                                        .clipShape(Rectangle())
                                        .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                                        .onTapGesture {
                                            self.isDetailViewPresented = true
                                                }
                                        .gesture(DragGesture()
                                                       .onEnded { gesture in
                                                           let swipeThreshold: CGFloat = 50 // Adjust the threshold as needed

                                                           if gesture.translation.width > swipeThreshold {
                                                               // Swipe right, move to the previous photo
                                                               navigateToPreviousPhoto()
                                                           } else if gesture.translation.width < -swipeThreshold {
                                                               // Swipe left, move to the next photo
                                                               navigateToNextPhoto()
                                                           }
                                                       }
                                                   )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal,0)
                    .sheet(isPresented: $isDetailViewPresented, content: {
                        DetailView(photo: $photo, showphotoInfo:$showphotoInfo, addFavorites:$addFavorites, processedImage:$processedImage, isDetailViewPresented: $isDetailViewPresented)
                            .presentationDetents([.fraction(0.08)])
                    })
                    .sheet(isPresented: $showphotoInfo, content: {
                        PhotoInfoView(asset: photo)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    })
                    .onAppear{
                        processedImage = fetchImage()
                        resizedImage = fetchImage()
                    }
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
                        ToolbarItem(placement: .navigationBarTrailing) {
                               Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.white)
                                    .contextMenu {
                                        Button(action: {
                                            PhotoController.shareImage(image: processedImage)
                                        }) {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                        
                                        Button(action: {
                                            // Edit action here
                                        }) {
                                            Label("Edit", systemImage: "square.and.pencil")
                                        }
                                        
                                        Button(action: {
                                            PhotoController.addImageToFavorites(asset: photo)
                                            addFavorites.toggle()
                                        }) {
                                            Label("Like", systemImage: addFavorites ?  "heart.fill" : "heart")
                                        }
                                        
                                        Button(action: {
                                            // Add to Album action here
                                        }) {
                                            Label("Add to Album", systemImage: "rectangle.stack.badge.plus")
                                        }
                                        
                                        Button(action: {
                                            // Delete action here
                                        }) {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                            
                            

                        }
                        
                    }
                    .foregroundStyle(Color.gray.opacity(0.1))
                    .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
                    .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
                    
            
        }
      
    }
    private func navigateToPreviousPhoto() {
            if currentIndex > 0 {
                currentIndex -= 1
                updateDisplayedPhoto()
            }
        }
    private func navigateToNextPhoto() {
            if currentIndex < photoAssets.count - 1 {
                currentIndex += 1
                updateDisplayedPhoto()
            }
        }

        private func updateDisplayedPhoto() {
            // Fetch and display the photo at the currentIndex
            photo = photoAssets[currentIndex]
            processedImage = fetchImage()
            resizedImage = fetchImage()
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



struct PreviewButtonView: View {
    var imageName: String
    var buttonText: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center,spacing: 10){
                Image(systemName: imageName)
                    .foregroundColor(.white)
                Text(buttonText)
                    .font(.custom("NetflixSans-Regular", size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}

struct DetailView: View {
    @ObservedObject var PhotoController = CorePhotoController()
    @Binding var photo : PHAsset
    @Binding var showphotoInfo: Bool
    @Binding var addFavorites: Bool
    @Binding var processedImage: UIImage
    @Binding  var isDetailViewPresented: Bool

    var body: some View {
        VStack(alignment: .leading,spacing: 18){
//            Divider()
            HStack(alignment: .center ,spacing: 80){
                Button {
                    withAnimation(.easeInOut(duration: 1)){
                        showphotoInfo.toggle()
                        isDetailViewPresented = false
                    }
                } label: {
                    
                    Text("Details")
                        .font(.custom("NetflixSans-Regular", size: 13))
                        .foregroundColor(.white)
                }
                
                Text("Template")
                    .font(.custom("NetflixSans-Regular", size: 13))
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity)

            
        }
    }
}

