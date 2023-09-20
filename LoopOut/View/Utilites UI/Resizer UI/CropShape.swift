//
//  CropShape.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/19.
//

import SwiftUI

struct ImageCropView: View {
@Environment(\.presentationMode) var pm
@State var imageWidth:CGFloat = 0
@State var imageHeight:CGFloat = 0
@Binding var image : UIImage

@State var dotSize:CGFloat = 13
var dotColor = Color.init(white: 1).opacity(0.9)

@State var center:CGFloat = 0
@State var activeOffset:CGSize = CGSize(width: 0, height: 0)
@State var finalOffset:CGSize = CGSize(width: 0, height: 0)

@State var rectActiveOffset:CGSize = CGSize(width: 0, height: 0)
@State var rectFinalOffset:CGSize = CGSize(width: 0, height: 0)

@State var activeRectSize : CGSize = CGSize(width: 200, height: 200)
@State var finalRectSize : CGSize = CGSize(width: 200, height: 200)


var body: some View {
    ZStack {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .overlay(GeometryReader{geo -> AnyView in
                DispatchQueue.main.async{
                    self.imageWidth = geo.size.width
                    self.imageHeight = geo.size.height
                }
                return AnyView(EmptyView())
            })

        Text("Crop")
            .padding(6)
            .foregroundColor(.white)
            .background(Capsule().fill(Color.blue))
            .offset(y: -250)
            .onTapGesture {
                let cgImage: CGImage = image.cgImage!
                let scaler = CGFloat(cgImage.width)/imageWidth
                if let cImage = cgImage.cropping(to: CGRect(x: getCropStartCord().x * scaler, y: getCropStartCord().y * scaler, width: activeRectSize.width * scaler, height: activeRectSize.height * scaler)){
                    image = UIImage(cgImage: cImage)
                }
                pm.wrappedValue.dismiss()
            }
        
        
        Rectangle()
            .stroke(lineWidth: 1)
            .foregroundColor(.white)
            .offset(x: rectActiveOffset.width, y: rectActiveOffset.height)
            .frame(width: activeRectSize.width, height: activeRectSize.height)
        
        Rectangle()
            .stroke(lineWidth: 1)
            .foregroundColor(.white)
            .background(Color.gray.opacity(0.02))
            .offset(x: rectActiveOffset.width, y: rectActiveOffset.height)
            .frame(width: activeRectSize.width, height: activeRectSize.height)
            .gesture(
                DragGesture()
                    .onChanged{drag in
                        let workingOffset = CGSize(
                            width: rectFinalOffset.width + drag.translation.width,
                            height: rectFinalOffset.height + drag.translation.height
                        )
                        self.rectActiveOffset.width = workingOffset.width
                        self.rectActiveOffset.height = workingOffset.height
                        
                        activeOffset.width = rectActiveOffset.width - activeRectSize.width / 2
                        activeOffset.height = rectActiveOffset.height - activeRectSize.height / 2
                    }
                    .onEnded{drag in
                        self.rectFinalOffset = rectActiveOffset
                        self.finalOffset = activeOffset
                    }
        )
        
        Image(systemName: "square.fill")
            .font(.system(size: 12))
            .background(Color.white)
            .frame(width: dotSize, height: dotSize)
            .foregroundColor(.black)
            .offset(x: activeOffset.width, y: activeOffset.height)
            .gesture(
                DragGesture()
                    .onChanged{drag in
                        let workingOffset = CGSize(
                            width: finalOffset.width + drag.translation.width,
                            height: finalOffset.height + drag.translation.height
                        )
                        
                        let changeInXOffset = finalOffset.width - workingOffset.width
                        let changeInYOffset = finalOffset.height - workingOffset.height
                        
                        if finalRectSize.width + changeInXOffset > 40 && finalRectSize.height + changeInYOffset > 40{
                            self.activeOffset.width = workingOffset.width
                            self.activeOffset.height = workingOffset.height
                            
                            activeRectSize.width = finalRectSize.width + changeInXOffset
                            activeRectSize.height = finalRectSize.height + changeInYOffset
                            
                            rectActiveOffset.width = rectFinalOffset.width - changeInXOffset / 2
                            rectActiveOffset.height = rectFinalOffset.height - changeInYOffset / 2
                        }
                        
                    }
                    .onEnded{drag in
                        self.finalOffset = activeOffset
                        finalRectSize = activeRectSize
                        rectFinalOffset = rectActiveOffset
                    }
        )
        
        Image(systemName: "square.fill")
            .font(.system(size: 12))
            .background(Color.white)
            .frame(width: dotSize, height: dotSize)
            .foregroundColor(.black)
            .offset(x: image.size.width, y: activeOffset.height)
            .gesture(
                DragGesture()
                    .onChanged{drag in
                        let workingOffset = CGSize(
                            width: finalOffset.width + drag.translation.width,
                            height: finalOffset.height + drag.translation.height
                        )
                        
                        let changeInXOffset = finalOffset.width - workingOffset.width
                        let changeInYOffset = finalOffset.height - workingOffset.height
                        
                        if finalRectSize.width + changeInXOffset > 40 && finalRectSize.height + changeInYOffset > 40{
                            self.activeOffset.width = workingOffset.width
                            self.activeOffset.height = workingOffset.height
                            
                            activeRectSize.width = finalRectSize.width + changeInXOffset
                            activeRectSize.height = finalRectSize.height + changeInYOffset
                            
                            rectActiveOffset.width = rectFinalOffset.width - changeInXOffset / 2
                            rectActiveOffset.height = rectFinalOffset.height - changeInYOffset / 2
                        }
                        
                    }
                    .onEnded{drag in
                        self.finalOffset = activeOffset
                        finalRectSize = activeRectSize
                        rectFinalOffset = rectActiveOffset
                    }
        )
    }
    .onAppear {
        activeOffset.width = rectActiveOffset.width - activeRectSize.width / 2
        activeOffset.height = rectActiveOffset.height - activeRectSize.height / 2
        finalOffset = activeOffset
    }
}

func getCropStartCord() -> CGPoint{
    var cropPoint : CGPoint = CGPoint(x: 0, y: 0)
    cropPoint.x = imageWidth / 2 - (activeRectSize.width / 2 - rectActiveOffset.width )
    cropPoint.y = imageHeight / 2 - (activeRectSize.height / 2 - rectActiveOffset.height )
    return cropPoint
}
}
