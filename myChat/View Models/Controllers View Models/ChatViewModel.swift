//
//  ChatViewModel.swift
//  myChat
//
//  Created by QwertY on 25.09.2022.
//

import UIKit
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView

class ChatViewModel: NSObject, ChatViewModelType {
    var user: MUser
    var chat: Box<MChat>
    var messages: Box<[MMessage]> = Box([])
    var chatListener: ListenerRegistration?
    var messageListener: ListenerRegistration?
    
    var sendMessageResult: Box<(Result<Void, Error>)>?
    
    required init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = Box(chat)
    }
    
    private var timer: Timer?
    
    func createMessagesObserver(completion: @escaping (Error?) -> Void) {
        messageListener = ListenerService.shared.messageObserve(chat: chat.value, completion: { result in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    StorageService.shared.downloadImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let image):
                            message.image = image
                            self.insertNewMessage(message: message)
                        case .failure(let error):
                            completion(error)
                        }
                    }
                } else {
                    self.insertNewMessage(message: message)
                }
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func createChatObserver(completion: @escaping (Error?) -> Void) {
        chatListener = ListenerService.shared.chatObserver(chat: chat.value, completion: { result in
            switch result {
            case .success(let chat):
                self.chat.value = chat
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func insertNewMessage(message: MMessage) {
        guard !messages.value.contains(message) else { return }
        messages.value.append(message)
        messages.value.sort()
    }
    
    func sendPhoto(image: UIImage) {
        StorageService.shared.uploadImageMessage(photo: image, to: chat.value) { result in
            switch result {
            case .success(let url):
                var message = MMessage(user: self.user, image: image)
                message.downloadURL = url
                FirestoreService.shared.sendMessage(chat: self.chat.value, message: message) { result in
                    switch result {
                    case .success(_):
                        self.sendMessageResult?.value = .success(Void())
                    case .failure(let error):
                        self.sendMessageResult?.value = .failure(error)
                    }
                    
                }
            case .failure(let error):
                self.sendMessageResult?.value = .failure(error)
            }
        }
    }
}

// MARK: - Messages Data Source
extension ChatViewModel: MessagesDataSource {
    
    var currentSender: SenderType {
        return Sender(senderId: user.id, displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages.value[indexPath.item]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.value.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item % 4 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ]
            )
        } else {
            return nil
        }
    }
}

// MARK: - Input Bar Accessory View Delegate
extension ChatViewModel: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat.value, message: message) { result in
            switch result {
            case .success(_):
                self.sendMessageResult?.value = .success(Void())
            case .failure(let error):
                self.sendMessageResult?.value = .failure(error)
            }
        }
        inputBar.inputTextView.text = ""
    }
}

// MARK: - Image Picker Controller Delegate
extension ChatViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        sendPhoto(image: image)
    }
}

// MARK: - Text View Delegate
extension ChatViewModel: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(stopTyping), userInfo: nil, repeats: false)
        
        FirestoreService.shared.sendTypingMessageStatus(chat: chat.value, typingStatus: true) { error in
            if let error = error {
                let topVC = UIApplication.topViewController()
                topVC?.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
        return true
    }
    
    @objc private func stopTyping() {
        FirestoreService.shared.sendTypingMessageStatus(chat: chat.value, typingStatus: false) { error in
            if let error = error {
                let topVC = UIApplication.topViewController()
                topVC?.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
    }
}
