//
//  ImageEncrypt.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/21.
//

import Foundation
import  SwiftUI
import CryptoKit

class ImageEncryption {
    // Store the encryption key securely
    func storeEncryptionKey(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "Victor-Kabike.LoopOut.encryptionKey",
            kSecValueData as String: keyData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to store encryption key: \(status)")
        }
    }
    // Retrieve the encryption key securely
    func retrieveEncryptionKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "Victor-Kabike.LoopOut.encryptionKey",
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let keyData = result as? Data {
            return SymmetricKey(data: keyData)
        } else {
            print("Failed to retrieve encryption key: \(status)")
            return nil
        }
    }

    func encryptData(_ data: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            let encryptedData = sealedBox.combined
            return encryptedData
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    func decryptData(_ encryptedData: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    func decryptAndDisplayImage(_ encryptedImageData: Data?, using key: SymmetricKey) -> UIImage? {
        guard let encryptedImageData = encryptedImageData else {
            return nil
        }
        
        if let decryptedImageData = decryptData(encryptedImageData, using: key) {
            return UIImage(data: decryptedImageData)
        }
        
        return nil
    }


}

