//
//  ContentView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/09.
//

import SwiftUI
import PhotosUI

struct ContentView: View {

    @ObservedObject var photoLibraryService = PhotoLibraryService()
       
    @State var showPreview:Bool = false
    @State var isSelected: Bool = false
    @Namespace private var animation
    @Namespace var namespace
    @State var showPhotoPreview = false
    var body: some View {
        NavigationStack{
            GeometryReader{ geo in
                ZStack(alignment: .top){
                    if let results = photoLibraryService.results{
                        ScrollView(showsIndicators: false){
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                Section{
                                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3),spacing: 8) {
                                        ForEach(0..<results.count, id: \.self) { photo in
                                            if let asset = results.object(at: photo) as? PHAsset {
                                                NavigationLink {
                                                    PhotoPreview( photo: asset)
                                                } label: {
                                                    PhotoTumbnailView(photo: asset)
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal,10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }else{
                        ProgressView {
                            Text("Fetching")
                        }.progressViewStyle(CircularProgressViewStyle())
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading){
                            VStack{
                                Button(action: {}) {
                                    Image(systemName: "camera")
                                        .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.semibold)
                                        .font(.headline)
                                    
                                    
                                }
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text("Loop Out")
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

                                                                                                                                                                                                                                                                                                      
