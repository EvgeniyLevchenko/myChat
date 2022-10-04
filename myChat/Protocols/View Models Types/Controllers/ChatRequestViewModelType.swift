//
//  ChatRequestViewModelType.swift
//  myChat
//
//  Created by QwertY on 23.09.2022.
//

import UIKit

protocol ChatRequestViewModelType {
    
    var chat: MChat { get }
    var friendUsername: Box<String> { get }
    var friendAvatarStringURL: Box<String> { get }
    
    var delegate: WaitingChatNavigation? { get }
    
    init(chat: MChat)
    
    func setDelegate(delegate: WaitingChatNavigation)
    func setImage(completion: @escaping (UIImage?) -> Void)
}
