//
//  ImageSaver.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/30.
//

import Foundation
import SwiftUI

class ImageSaver: NSObject {
    var completionHandler: ((Error?) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completionHandler?(error)
    }
}
