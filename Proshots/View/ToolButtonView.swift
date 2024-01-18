//
//  ToolButtonView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/23.
//

import Foundation
import SwiftUI

struct ButtonView: View {
    let imageName: String
    let buttonText: String
    let action: () -> Void
    var body: some View {
        Button(action: {action()}) {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(buttonText)
                    .font(.custom("NetflixSans-Regular", size: 10))
                    .foregroundColor(.white)
            }
        }
       
    }
}

struct CanvasButtonView: View {
    let imageName: String
    let buttonText: String
    let buttonsubText:String
    let action: () -> Void
    var body: some View {
        Button(action: {action()}) {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(buttonText)
                    .font(.custom("NetflixSans-Regular", size: 10))
                    .foregroundColor(.white)
                Text(buttonsubText)
                    .font(.custom("NetflixSans-Light", size: 8))
                    .foregroundColor(.white)
                
            }
        }
       
    }
}

struct ButtonData {
    let imageName: String
    let buttonText: String
}
