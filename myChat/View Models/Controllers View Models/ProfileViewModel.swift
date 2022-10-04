//
//  ProfileViewModel.swift
//  myChat
//
//  Created by QwertY on 23.09.2022.
//

import Foundation
import SDWebImage

class ProfileViewModel: ProfileViewModelType {
    
    var user: MUser
    
    var username: Box<String> {
        return Box(user.username)
    }
    
    var description: Box<String> {
        return Box(user.description)
    }
    
    var avatarStringURL: Box<String> {
        return Box(user.avatarStringURL)
    }
    
    required init(user: MUser) {
        self.user = user
    }
    
    func setImage(completion: @escaping (UIImage?) -> Void) {
        let imageView = UIImageView()
        let avatarImageURL = URL(string: avatarStringURL.value)
        DispatchQueue.main.async {
            imageView.sd_setImage(with: avatarImageURL)
            completion(imageView.image)
        }
    }
    
    func sendMessage(message: String, completion: @escaping (Error?) -> Void) {
        FirestoreService.shared.createWaitingChat(message: message, receiver: user) { result in
            switch result {
            case .success():
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
