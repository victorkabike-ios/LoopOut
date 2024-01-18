//
//  SecurityController.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/20.
//

import Foundation
import LocalAuthentication

class SecurityController: ObservableObject {
    func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock to access your photos") { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
}
