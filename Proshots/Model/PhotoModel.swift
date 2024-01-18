//
//  PhotoModel.swift
//  LoopOut
//
//  Created by victor kabike on 2023/07/09.
//

import SwiftUI
import Photos

struct PhotoModel: Identifiable, Equatable {
    let id = UUID()
    let asset: PHAsset
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
            return lhs.id == rhs.id && lhs.asset == rhs.asset
        }
}
