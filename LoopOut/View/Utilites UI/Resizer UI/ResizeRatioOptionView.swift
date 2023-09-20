//
//  ResizeRatioOptionView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/31.
//

import Foundation
import SwiftUI
import Photos
struct ResizeRatioOptionView: View {
    @Binding var selectedRatioOption: ResizeRatioOption
    @Binding var resizedImage: UIImage?
    let originalImage: UIImage
    let resizerManager: ResizerManager
    let selectedOption: ResizeOption  // Add this line

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            LazyHStack(alignment: .bottom){
                ForEach(ResizeRatioOption.allCases, id: \.title) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 1)){
                            selectedRatioOption = option
                            resizedImage = resizerManager.resizeImage(originalImage, targetSize: option.ratioSize!, resizeOption: selectedOption)!
                        }
                    }) {
                        VStack {
                            ZStack{
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(lineWidth: 1)
                                    .foregroundStyle(Color.gray.opacity(0.2))
                                    .frame(width: option.IconSize?.width, height: option.IconSize?.height)
                                option.icon
                                    .resizable()
                                    .clipped()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)

                            }

                            Text(option.label)
                                .font(.custom("NetflixSans-Bold", size: 10))
                                .foregroundColor(.white)
                                .bold()
                        }

                    }
                }
            }

        }.padding(.leading)
    }
}


