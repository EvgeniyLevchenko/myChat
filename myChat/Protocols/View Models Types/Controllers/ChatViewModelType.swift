//
//  ChatViewModelType.swift
//  myChat
//
//  Created by QwertY on 25.09.2022.
//

import UIKit
import FirebaseFirestore

protocol ChatViewModelType {
    var user: MUser { get }
    var chat: Box<MChat> { get }
    var messages: Box<[MMessage]> { get }
    var messageListener: ListenerRegistration? { get }
    var sendMessageResult: Box<Result<Void, Error>>? { get }

    init(user: MUser, chat: MChat)
    
    func createMessagesObserver(completion: @escaping (Error?) -> Void)
    func createChatObserver(completion: @escaping (Error?) -> Void)
    func insertNewMessage(message: MMessage)
    func sendPhoto(image: UIImage)
}
