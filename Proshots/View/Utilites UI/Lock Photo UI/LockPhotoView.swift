//
//  LockPhotoView.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/20.
//

import Foundation
import SwiftUI

struct LockPhotoView: View {
    let securityController = SecurityController()
    var body: some View {
        VStack{
            LockPhotoViewController(securityController: securityController)
        }
    }
}
