//
//  FirestoreService.swift
//  myChat
//
//  Created by QwertY on 05.09.2022.
//

import Firebase
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    var currentUser: MUser!
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let muser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                self.currentUser = muser
                completion(.success(muser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String, email: String, username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(avatarImage: avatarImage, username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        var muser = MUser(username: username!,
                          email: email,
                          avatarStringURL: "not exist",
                          description: description!,
                          sex: sex!,
                          id: id)
        
        StorageService.shared.upload(photo: avatarImage!) { (result) in
            switch result {
            case .success(let url):
                muser.avatarStringURL = url.absoluteString
                self.usersRef.document(muser.id).setData(muser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(muser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username,
                         friendAvatarStringURL: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendID: currentUser.id)

        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
            }
            
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void())) 
            }
        }
    }
    
    func deleteWaitingChat(chat: MChat, completion: @escaping (Error?) -> Void) {
        waitingChatsRef.document(chat.friendID).delete { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            self.deleteMessages(chat: chat) { result in
                switch result {
                case .success():
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }
    
    func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendID).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else {
                        completion(.failure(FirestoreError.documentIdError))
                        return
                    }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendID).collection("messages")
        var messages = [MMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = querySnapshot?.documents else {
                completion(.failure(FirestoreError.noDocumentsError))
                return
            }
            for document in documents {
                guard let message = MMessage(document: document) else {
                    print("message error")
                    completion(.failure(FirestoreError.noMessageError))
                    return
                }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: MChat, completion: @escaping (Error?) -> Void) {
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    self.createActiveChat(chat: chat, messages: messages) { result in
                        switch result {
                        case .success():
                            completion(nil)
                        case .failure(let error):
                            completion(error)
                        }
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendID).collection("messages")
        let friendActiveChatsRef = usersRef.document(chat.friendID).collection("activeChats")
        let friendMessageRef = friendActiveChatsRef.document(currentUser.id).collection("messages")
        
        let chatForFriend = MChat(friendUsername: currentUser.username,
                                  friendAvatarStringURL: currentUser.avatarStringURL,
                                  lastMessageContent: chat.lastMessageContent,
                                  friendID: currentUser.id)
        activeChatsRef.document(chat.friendID).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendActiveChatsRef.document(chatForFriend.friendID).setData(chatForFriend.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                for message in messages {
                    messageRef.addDocument(data: message.representation) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        friendMessageRef.addDocument(data: message.representation) { error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            completion(.success(Void()))
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendID).collection("activeChats").document(currentUser.id)
        let currentUserRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendID)
        let friendMessageRef = friendRef.collection("messages")
        let myMessagesRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendID).collection("messages")
        
        let friendChat = MChat(friendUsername: currentUser.username,
                               friendAvatarStringURL: currentUser.avatarStringURL,
                               lastMessageContent: message.content,
                               friendID: currentUser.id,
                               isFriendTyping: false)
        
        let currentUserChat = MChat(friendUsername: chat.friendUsername,
                                    friendAvatarStringURL: chat.friendAvatarStringURL,
                                    lastMessageContent: message.content,
                                    friendID: chat.friendID)
        
        friendRef.setData(friendChat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            currentUserRef.setData(currentUserChat.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                friendMessageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    myMessagesRef.addDocument(data: message.representation) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            }
        }
    }
    
    func sendTypingMessageStatus(chat: MChat, typingStatus: Bool, completion: @escaping (Error?) -> Void) {
        let friendRef = usersRef.document(chat.friendID).collection("activeChats").document(currentUser.id)
        let friendChat = MChat(friendUsername: currentUser.username,
                               friendAvatarStringURL: currentUser.avatarStringURL,
                               lastMessageContent: chat.lastMessageContent,
                               friendID: currentUser.id,
                               isFriendTyping: typingStatus)
        friendRef.setData(friendChat.representation) { error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
}
