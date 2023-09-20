//
//  ContentView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/09.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @ObservedObject var albumCollectionLibraryService =  CollectionLibraryService()
    @ObservedObject var photoLibraryService = PhotoLibraryService()
    @ObservedObject var corePhotoController = CorePhotoController()
    @State var showPreview:Bool = false
    @State var isSelected: Bool = false
    @State var phResults: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    @State private var selectedPhotoIndex: Int? = nil
    @State private var isDeleteAlertShown = false
    
    @State var isAlbumPickerPresented: Bool = false
    @State var assetCollection: [PHAssetCollection] = []
    @State var selectPhoto = false
    @State var selectedPhotos = [PHAsset]()
    @State var isSelectedPhoto = false
    @State var showPhotoPreview = false
    @State private var selectedAssets: PHAsset? = nil
    var body: some View {
        NavigationStack{
            GeometryReader{ geo in
                ZStack(alignment: .top){
                    if let results = photoLibraryService.results{
                        PhotoGridView(selectPhoto: $selectPhoto)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .environmentObject(photoLibraryService)
                            .onAppear{
                                self.phResults = results
                                
                            }
                        
                    }else{
                        ProgressView {
                            Text("Fetching")
                        }.progressViewStyle(CircularProgressViewStyle())
                    }
                    
                }
                .navigationTitle("Loop Out")
            
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .edgesIgnoringSafeArea(.horizontal)
                    .toolbar {
//                        ToolbarItem(placement: .navigationBarLeading){
//                            VStack{
//                                Button(action: {}) {
//                                    Image(systemName: "camera")
//                                        .symbolRenderingMode(.monochrome)
//                                        .foregroundStyle(Color.white)
//                                        .fontWeight(.semibold)
//                                        .font(.headline)
//
//
//                                }
//                            }
//                        }
//                        ToolbarItem(placement: .principal) {
//                            Text("Loop Out")
//                                .font(.custom("netflixsans-black", size: 20))
//                                .foregroundColor(Color.white)
//                                .fontWeight(.heavy)
//                        }
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
            }.onAppear{
                photoLibraryService.requestAuthorization { error in
                    Alert(title: Text("Access Denied"))
                }
            }
            .sheet(isPresented: $isAlbumPickerPresented) {
                ListAlbumsView(selectedAsset: $selectedAssets, isPresented: $isAlbumPickerPresented, albumCollections: assetCollection)
                    .onAppear{
                        albumCollectionLibraryService.fetchAlbums { collections in
                            self.assetCollection = collections
                        }
                    }
                    .onDisappear{
                        photoLibraryService.requestAuthorization { error in
                            Alert(title: Text("Access Denied"))
                        }
                    }
                   
            }
            
                
        }
    }
    private func fetchImage(image:PHAsset) -> UIImage {
         let semaphore = DispatchSemaphore(value: 0)
         var selectedPhoto = UIImage()
         photoLibraryService.fetchImage(byLocalIdentifier: image.localIdentifier, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill) { fetchedImage in
             if let fetchedImage = fetchedImage {
                 selectedPhoto = fetchedImage
             }
             semaphore.signal()
         }
         
         semaphore.wait()
         return selectedPhoto
     }
    private func contextMenuButton(for option: MenuOption, asset: PHAsset) -> some View {
           Button(action: {
               handleAction(for: option, asset: asset)
           }) {
               Label(option.label, systemImage: option.systemImageName)
                  
           }
       }
       private func handleAction(for option: MenuOption, asset: PHAsset) {
           switch option {
           case .share:
               // Handle share action
               corePhotoController.shareImage(image: fetchImage(image: asset))
               break
           case .favorite:
               // Handle favorite action
               corePhotoController.addImageToFavorites(asset: asset)
               break
           case .duplicate:
               // Handle duplicate action
               corePhotoController.duplicatePhoto(asset: asset)
               break
           case .addToAlbum:
               // Handle add to album action
               isAlbumPickerPresented = true
               selectedAssets = asset
               break
           case .delete:
               // Handle delete action
               photoLibraryService.requestAndDeletePhoto(asset: asset) { success, error in
                   photoLibraryService.fetchAllPhotos()
                                  }
              
               

           }
       }
}

extension ContentView {
    enum MenuOption: String, CaseIterable {
        case share
        case favorite
        case duplicate
        case addToAlbum = "Add to Album"
        case delete
        
        var label: String {
            rawValue.capitalized
        
        }
        
        var systemImageName: String {
            switch self {
            case .share: return "square.and.arrow.up"
            case .favorite: return "heart"
            case .duplicate: return "doc.on.doc"
            case .addToAlbum: return "plus.square.on.square"
            case .delete: return "trash"
            }
        }
    }
}

                                                                                                                                                                                                                                                                                                
