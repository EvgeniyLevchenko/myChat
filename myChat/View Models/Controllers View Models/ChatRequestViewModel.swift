//
//  ChatRequestViewModel.swift
//  myChat
//
//  Created by QwertY on 23.09.2022.
//

import UIKit

class ChatRequestViewModel: ChatRequestViewModelType {

    var chat: MChat
    
    var friendUsername: Box<String> {
        return Box(chat.friendUsername)
    }
    
    var friendAvatarStringURL: Box<String> {
        return Box(chat.friendAvatarStringURL)
    }
    
    weak var delegate: WaitingChatNavigation?
    
    required init(chat: MChat) {
        self.chat = chat
    }
    
    func setDelegate(delegate: WaitingChatNavigation) {
        self.delegate = delegate
    }
    
    func setImage(completion: @escaping (UIImage?) -> Void) {
        let imageView = UIImageView()
        let avatarImageURL = URL(string: friendAvatarStringURL.value)
        DispatchQueue.main.async {
            imageView.sd_setImage(with: avatarImageURL)
            completion(imageView.image)
        }
    }
}
