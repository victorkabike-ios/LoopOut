//
//  PhotoGridView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/28.
//

import Foundation
import SwiftUI
import Photos

struct PhotoWithDate {
    let photo: PHAsset
    let creationDate: Date
}

struct PhotoGridView: View {
    @EnvironmentObject var photoLibraryService : PhotoLibraryService
    @ObservedObject var corePhotoController = CorePhotoController()
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 3)
//    @Binding var results: PHFetchResult<PHAsset>
    @Binding var selectPhoto: Bool
    @State private var selectedAssetSet: Set<PHAsset> = []
    @State private var selectActive = false
    
    @State var isAlbumPickerPresented: Bool = false
    @State private var selectedAssets: PHAsset? = nil
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    @State var photoAssets: [PHAsset] = []
    func getHeaderText(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return dateFormatter.string(from: date)
        }
    }
    // Function to convert PHFetchResult to an array
    private func convertFetchResultToArray(fetchResult: PHFetchResult<PHAsset>) {
           for index in 0..<fetchResult.count {
               let asset = fetchResult.object(at: index)
               photoAssets.append(asset)
           }
       }
    var body: some View {
        NavigationStack{
            ZStack{
                ScrollView(.vertical,showsIndicators: false){
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        if let results = photoLibraryService.results{
                            // Convert PHFetchResult to Array
                            let resultsArray = (0..<results.count).compactMap { results.object(at: $0) }
                            
                            // Group your photos by date
                            let groupedResults = Dictionary(grouping: resultsArray) { (element) -> Date in
                                // Convert asset.creationDate to the start of the day for grouping
                                return Calendar.current.startOfDay(for: element.creationDate!)
                            }
                            
                            ForEach(groupedResults.keys.sorted(by: >), id: \.self) { key in
                                let headerText = getHeaderText(for: key)
                                Section{
                                    LazyVGrid(columns: columns, spacing: 0) {
                                        ForEach(groupedResults[key]!, id: \.self) { asset in
                                            PhotoView(asset: asset, photoAssets: photoAssets )
                                            .onAppear{convertFetchResultToArray(fetchResult: results)}
                                            .environmentObject(photoLibraryService)
                                            .contextMenu {
                                                ForEach(MenuOption.allCases, id: \.self) { option in
                                                    contextMenuButton(for: option, asset: asset)
                                                }
                                            }
                                        }
                                    }
                                } header: {
                                    HStack{
                                                           
                                        Text("\(headerText)")
                                            .foregroundColor(.white)
                                            .font(.custom("NetflixSans-Bold", size: 18))
                                        Spacer()
//                                        Button(action: {
//                                            selectActive.toggle()
//                                            if !selectActive {
//                                                // Clear the selection when switching back from "Select" mode
//                                                selectedAssetSet.removeAll()
//                                            }
//                                        }) {
//                                            Image(systemName: selectActive ? "checkmark.circle.fill" : "checkmark.circle")
//                                                .resizable()
//                                                .frame(width: 20, height: 20)
//                                                .foregroundColor(Color(uiColor: .systemGray3))
//                                                .bold()
//
//                                        }
                                    }.padding()
                                }
                            }
                        }
                    }
                }
                
            }

            .onAppear{
                photoLibraryService.requestAuthorization { error in
                    Alert(title: Text("Access Denied"))
                }
            }
        }
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
                   photoLibraryService.requestAuthorization()
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
}


struct PhotoView: View {
    @EnvironmentObject var photoLibraryService: PhotoLibraryService
    @ObservedObject var corePhotoController = CorePhotoController()
    @State var isAlbumPickerPresented: Bool = false
    @State private var selectedAssets: PHAsset? = nil
    let asset: PHAsset
    var photoAssets : [PHAsset]
    var body: some View {
        NavigationStack{
            NavigationLink {
                PhotoPreview(photo: asset, photoAssets: photoAssets)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationBarBackButtonHidden()
            } label: {
                PhotoTumbnailView(photo: asset)
                  
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

}

extension PhotoGridView {
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
