//
//  StorageService.swift
//  myChat
//
//  Created by QwertY on 08.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()

    let storageRef = Storage.storage().reference()
    
    private var avatarsRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var chatsRef: StorageReference {
        return storageRef.child("chats")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarsRef.child(currentUserId).putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(StorageError.unknown))
                }
                return
            }
            
            self.avatarsRef.child(self.currentUserId).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(StorageError.unknown))
                    }
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    func uploadImageMessage(photo: UIImage, to chat: MChat, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let chatName = [chat.friendID, uid].joined()
        self.chatsRef.child(chatName).child(imageName).putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.chatsRef.child(chatName).child(imageName).downloadURL { url, error in
                guard let downloadURL = url else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(StorageError.unknown))
                    }
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(StorageError.unknown))
                }
                return
            }
            let image = UIImage(data: imageData)
            completion(.success(image))
        }
    }
}
