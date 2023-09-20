//
//  ResizerView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/12.
//

import BrightroomUI
import BrightroomEngine
import SwiftUI
import Photos
import PhotosUI
import UIKit
struct ResizerView: View {
    @State var editingStack: EditingStack?
    @State private var isPickerPresented = true
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedRatioOption: ResizeRatioOption = .custom
    @State private var selectedOption: ResizeOption = .fit
    @State var originalImage: UIImage?
    @State private var resizedImage: UIImage?
    @State private var cropImage: UIImage = UIImage()
    @State private var scale: CGFloat = 0.5
    @State private var aspectRatioLock = true
    @State  var showAspectRatio: Bool = false
    let resizerManager = ResizerManager()
    let imageSaver = ImageSaver()
    @State  var showCropView: Bool = false
    @State  var showRotateView: Bool = false
    @State private var showingConfirmation = false
    @State private var saveError: Error?
    @Environment(\.dismiss) var dismissAction
    @ObservedObject var resizingToolViewController = ResizingToolViewController()
    @State private var  selectedResizeTool: ResizingTools  = .Aspectratio
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(alignment: .center){
                    ZStack{
                        if let resizedImage = resizedImage {
                            Image(uiImage: resizedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .overlay(content: {
                                    if showCropView{
                                        SwiftUICropView(editingStack: EditingStack(imageProvider: ImageProvider(image: resizedImage)))
                                    }
                                })
                            // Adjust size as needed
                        }else if originalImage != nil {
                            Image(uiImage: originalImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onAppear{self.editingStack = EditingStack(imageProvider: ImageProvider(image: originalImage!))}
                                .overlay(content: {
                                    if showCropView{
                                        SwiftUICropView(editingStack: editingStack!)
                                            .onAppear {
                                                 editingStack?.start()
                                               }
                                            
                                       

                                    }
                                })
                              
                            // Adjust size as needed
                                .padding()
                               
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame( maxHeight: .infinity)
                    if originalImage != nil {
                        VStack(alignment: .leading){
                            VStack{
                                if !showCropView && showAspectRatio{
                                    ResizeRatioOptionView(selectedRatioOption: $selectedRatioOption, resizedImage: $resizedImage, originalImage: originalImage!, resizerManager: resizerManager, selectedOption: selectedOption)
                                }else if showRotateView{
                                    EmptyView()
                                }
                                
                              
                                Divider()
                                HStack(spacing: 60){
                                    Button(action: {showAspectRatio.toggle()}) {
                                        Text("Aspect ratio")
                                            .font(.custom("NetflixSans-Regular", size: 12))
                                            .foregroundColor(.white)
                                    }

                                    Button(action: {showCropView.toggle()}) {
                                        Text("Crop")
                                            .font(.custom("NetflixSans-Regular", size: 12))
                                            .foregroundColor(.white)
                                    }
                                    Button(action: {showRotateView}) {
                                        Text("Rotate")
                                            .font(.custom("NetflixSans-Regular", size: 12))
                                            .foregroundColor(.white)
                                    }
                                   
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.white)
                                   
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                        }
                        .frame( height: 200, alignment: .bottom)
                        .background(Color.gray.opacity(0.1))
                     
                    }
                   
                }
                
            }
//            .sheet(isPresented: $showAspectRatio, content: {
//            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                        Button(action: {
                            showingConfirmation = true
                            imageSaver.completionHandler = { error in
                                if let error = error {
                                    saveError = error
                                } else {
                                }
                            }
                        }) {
                            Text("Save")
                                .font(.custom("NetflixSans-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal,8)
                                .bold()
                                .background(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                            
                                .clipShape(Capsule())
                        }
//                        .alert("Save Error", isPresented: $saveError) {
//                            Alert(title: Text("Save Error"), message: Text(saveError?.localizedDescription ?? "Unknown error"))
//                        }
                        
                    }
                }
            }
            .foregroundStyle(Color.gray.opacity(0.1))
            .toolbarBackground(Color.gray.opacity(0.1), for: .navigationBar)
            .toolbarBackground(Color.init(uiColor: .white), for: .bottomBar)
            .photosPicker(isPresented: $isPickerPresented, selection: $selectedItem,matching: .images,photoLibrary: .shared())
            .onChange(of: selectedItem) { newItem in
                Task {
                    // Retrieve selected asset in the form of Data
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let  originalImage = UIImage(data: data){
                            self.originalImage = originalImage
                            self.cropImage = originalImage
                            self.showAspectRatio = true
                        }
                    }
                }
                
            }
            .confirmationDialog("Save Changes", isPresented: $showingConfirmation) {
                Button("Save Changes", role: .destructive) {
                    if showCropView{
                        // This closure is called when the user finishes editing the image.
                        do {
                            // Render the edited image
                            let rendered = try self.editingStack?.makeRenderer().render()
                            let editedImage =  rendered?.uiImage
                            // Update the resizedImage here
                            self.resizedImage = editedImage
                        } catch {
                            // Handle any errors here
                            print("An error occurred: \(error)")
                        }
                    }
                    imageSaver.writeToPhotoAlbum(image: resizedImage!)
                }
            }
        }
    }
}
class ResizingToolViewController: ObservableObject {
    @Published var currentTool: ResizingTools = .Aspectratio
}
enum ResizingTools {
    case Aspectratio
    case crop
    case rotate
}
struct collegeView: View {
    var body: some View {
        VStack{
            Text("Resizerview")
        }
    }
}

