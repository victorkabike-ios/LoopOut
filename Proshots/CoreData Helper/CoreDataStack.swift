//
//  CoreDataStack.swift
//  LoopOut
//
//  Created by victor kabike on 2023/08/21.
//

import CoreData

import CoreData
import CryptoKit
import Security
enum ImageError: Error {
    case conversionFailed
}

enum EncryptionError: Error {
    case encryptionFailed
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hidden") // Replace with your Core Data model name
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Save Context
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    func createHiddenAlbum(albumName: String){
            let context = persistentContainer.viewContext
            let album = HiddenAlbum(context: context)
            
        album.id = UUID().uuidString
        album.name = albumName
            album.creationDate = Date()
            
            saveContext()
        }
    func fetchAlbum(withName name: String) -> HiddenAlbum? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<HiddenAlbum> = HiddenAlbum.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let albums = try context.fetch(fetchRequest)
            return albums.first
        } catch {
            print("Error fetching album: \(error.localizedDescription)")
            return nil
        }
    }

    func fetchAllAlbums() -> [HiddenAlbum] {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<HiddenAlbum> = HiddenAlbum.fetchRequest()
            
            do {
                let albums = try context.fetch(fetchRequest)
                return albums
            } catch {
                print("Error fetching albums: \(error.localizedDescription)")
                return []
            }
        }
    // MARK: - Hidden Album CRUD Operations
    func createPhoto(album: HiddenAlbum, imageData: Data){
           let context = persistentContainer.viewContext
           let photo = HiddenPhotos(context: context)
           
        photo.id = UUID().uuidString
           photo.imageData = imageData
           photo.creationDate = Date()
           
           album.addToPhotos(photo)
           
           saveContext()
       }

    func fetchAllHiddenAlbums() -> [HiddenAlbum] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<HiddenAlbum> = HiddenAlbum.fetchRequest()
        
        do {
            let hiddenAlbums = try context.fetch(fetchRequest)
            return hiddenAlbums
        } catch {
            print("Error fetching hidden albums: \(error.localizedDescription)")
            return []
        }
    }
    
    // Add additional methods for updating, deleting, etc.
    
    // Generate a new symmetric key
        func generateNewEncryptionKey() -> SymmetricKey {
            return SymmetricKey(size: .bits256) // You can choose a different key size if needed
        }
    // Store the symmetric key in the Keychain
        func storeEncryptionKey(_ key: SymmetricKey) {
            do {
                let keyData = key.withUnsafeBytes { Data($0) }

                let query: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: "Victor-Kabike.LoopOut.encryptionKey", // Use a unique identifier
                    kSecValueData as String: keyData,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Adjust the accessibility level as needed
                ]

                let status = SecItemAdd(query as CFDictionary, nil)
                if status != errSecSuccess {
                    print("Failed to store encryption key: \(status)")
                }
            } catch {
                print("Error storing encryption key: \(error)")
            }
        }
    // Retrieve the stored symmetric key from the Keychain
        func retrieveEncryptionKey() -> SymmetricKey? {
            do {
                let query: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: "Victor-Kabike.LoopOut.encryptionKey", // Use the same unique identifier
                    kSecReturnData as String: kCFBooleanTrue,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]

                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                if status == errSecSuccess, let keyData = result as? Data {
                    return SymmetricKey(data: keyData)
                } else if status == errSecItemNotFound {
                    // Key not found, it may not be stored yet
                    return nil
                } else {
                    print("Failed to retrieve encryption key: \(status)")
                    return nil
                }
            } catch {
                print("Error retrieving encryption key: \(error)")
                return nil
            }
        }
}

