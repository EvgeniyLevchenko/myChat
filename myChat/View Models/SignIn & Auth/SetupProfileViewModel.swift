//
//  SetupProfileViewModel.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseAuth
import SDWebImage

class SetupProfileViewModel: NSObject, SetupProfileViewModelType {
    
    var currentMUser: MUser?
    var currentUser: User
    
    var username: String {
        if let username = currentUser.displayName {
            return username
        }
        return ""
    }
    
    var avatarURL: URL? {
        return currentUser.photoURL
    }
    
    var avatarImage: Box<UIImage?> = Box(nil)
    
    private var email: String {
        return currentUser.email ?? "nil"
    }

    var mainTabBarController: MainTabBarController? {
        guard let currentMUser = currentMUser else { return nil }
        return MainTabBarController(currentUser: currentMUser)
    }
    
    required init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func saveProfileWith(username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.saveProfileWith(
            id: currentUser.uid,
            email: email,
            username: username,
            avatarImage: avatarImage,
            description: description,
            sex: sex) { result in
                switch result {
                case .success(let mUser):
                    self.currentMUser = mUser
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

extension SetupProfileViewModel {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        avatarImage.value = image
    }
}
