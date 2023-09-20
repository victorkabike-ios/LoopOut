//
//  HiddenAlbumView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/21.
//

import SwiftUI
import Photos
import PhotosUI
import CryptoKit


struct HiddenAlbumView: View {
    let coreDataManager = CoreDataManager.shared
    let imageEncryption = ImageEncryption()
    @State private var albumName = ""
    @State private var encryptedData =  Data()
    // Add more state variables as needed
    @State private var showingAlert = false
    @State private var encrypting = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedItems = [PhotosPickerItem]()
       @State private var selectedImages = [UIImage]()
    func photoPicker() {
        showPhotoPicker.toggle()
       }
    var body: some View {
        let alertView = alertContent()
        let toolbarBackgroundView = Color.init(uiColor: .white)
        
        return NavigationStack {
            ZStack {
                ScrollView(.vertical) {
                    content
                }
            }
            .alert("New Hidden Album", isPresented: $showingAlert){
                alertView
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItems)
            .onChange(of: selectedItems) { _ in
                handleSelectionChange()
                EmptyView() // Wrap in a view
            }
            
            .confirmationDialog("Save this Album", isPresented: $encrypting) {
                Button("Save", role: .destructive) {
                    handleConfirmation()
                      }
                
            }
            .navigationTitle("Locked Albums")
//            .navigationBarTitleDisplayMode(.largeTitle)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    leadingToolbarItem
//                }
//                ToolbarItem(placement: .principal) {
//                    principalToolbarItem
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingToolbarItem
                }
            }
            .foregroundStyle(Color.gray.opacity(0.1))
            .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
            .toolbarBackground(toolbarBackgroundView, for: .bottomBar)
        }
    }

    // Sub-expressions for improved readability and maintainability
    @ViewBuilder
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 2),spacing: 8){
                ForEach(coreDataManager.fetchAllHiddenAlbums()) { hiddenAlbum in
                        NavigationLink {
                            let photos = hiddenAlbum.photos as? Set<HiddenPhotos> ?? []
                            PhotoDataDisplayView(albumName: hiddenAlbum.name ?? "Unknown", photoSet: photos)
                                .navigationBarBackButtonHidden(true)
                        } label: {
                            VStack(alignment: .leading){
                                ZStack{
                                    let photos = Array(hiddenAlbum.photos as? Set<HiddenPhotos> ?? [])
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 100, height: 100)
                                        .foregroundStyle(Color.gray.opacity(0.1))
                                    if let imageData = photos.first?.imageData, let image = decryptingImage(photoData: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .interpolation(.high)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 160, height: 160)
                                            .clipped()
                                    }
                                }
                                VStack(alignment: .leading){
                                    Text(hiddenAlbum.name ?? "")
                                        .foregroundColor(Color.white)
                                        .font(.custom("netflixsans-Regular", size: 12))
                                }
                                
                            }
                            
                            .frame(width: 180, height: 250)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                        }
                        
                        
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func alertContent() -> some View {
        VStack {
            TextField("album title", text: $albumName)
                .foregroundColor(.white)
            Button("OK", action: photoPicker)
        }
        Text("Enter a name of this album.")
    }
    @ViewBuilder
    private var leadingToolbarItem: some View {
        Button(action: {}) {
            Image(systemName: "camera")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.white)
                .fontWeight(.semibold)
                .font(.headline)
        }
    }

    @ViewBuilder
    private var principalToolbarItem: some View {
        Text("Locked Albums")
            .font(.custom("netflixsans-black", size: 20))
            .foregroundColor(Color.white)
            .fontWeight(.heavy)
    }

    @ViewBuilder
    private var trailingToolbarItem: some View {
        Button(action: {
            showingAlert.toggle()
        }) {
            Image(systemName: "plus")
                .font(.custom("NetflixSans-Bold", size: 14))
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .bold()
                .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
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
    func handleSelectionChange() {
        Task {
            selectedImages.removeAll()
            
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
            }
            encrypting = true
        }
    }
    func handleConfirmation() {
        
        coreDataManager.createHiddenAlbum(albumName: albumName)
        
        do {
            try encryptAndStoreSelectedPhotos(selectedImages)
        } catch {
            // Handle error
            print(error)
        }
    }

    func encryptAndStoreSelectedPhotos(_ selectedImages: [UIImage]) throws {
        guard let storedKey = coreDataManager.retrieveEncryptionKey() else {
            // Generate and store a new encryption key (usually done at app startup)
            let newKey = coreDataManager.generateNewEncryptionKey()
            coreDataManager.storeEncryptionKey(newKey)
             // Add this return statement to exit the function
            return
        }
        let album = coreDataManager.fetchAlbum(withName: albumName)!
        for selectedImage in selectedImages {
            guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                throw ImageError.conversionFailed
            }

            guard let encryptedData = imageEncryption.encryptData(imageData, using: storedKey) else {
                throw EncryptionError.encryptionFailed
            }

            coreDataManager.createPhoto(album: album, imageData: encryptedData)
        }
    }


    enum ImageError: Error {
        case conversionFailed
    }

    enum EncryptionError: Error {
        case encryptionFailed
    }
}

