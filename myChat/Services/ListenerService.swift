//
//  ListenerService.swift
//  myChat
//
//  Created by QwertY on 09.09.2022.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class ListenerService {
    
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()

    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var currentUserID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    func usersObserve(users: [MUser], completion: @escaping (Result<[MUser], Error>) -> Void) -> ListenerRegistration? {
        var users = users
        let usersListener = usersRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FirestoreError.unknown))
                }
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let mUser = MUser(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !users.contains(mUser) else { return }
                    guard mUser.id != self.currentUserID else { return }
                    users.append(mUser)
                case .modified:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users[index] = mUser
                case .removed:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        
        return usersListener
    }
    
    func waitingChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsReference = db.collection(["users", currentUserID, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FirestoreError.unknown))
                }
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else {  return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func activeChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsReference = db.collection(["users", currentUserID, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FirestoreError.unknown))
                }
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else {  return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    print("chat added")
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    print("chat modified")
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func messageObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        let reference = usersRef.document(currentUserID).collection("activeChats").document(chat.friendID).collection("messages")
        let messageListener = reference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FirestoreError.unknown))
                }
                return
            }
             
            snapshot.documentChanges.forEach { diff in
                guard let message = MMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        
        return messageListener
    }
    
    func chatObserver(chat: MChat, completion: @escaping (Result<MChat, Error>) -> Void) -> ListenerRegistration? {
        let reference = usersRef.document(currentUserID).collection("activeChats").document(chat.friendID)
        let chatListener = reference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(FirestoreError.unknown))
                }
                return
            }
            
            guard let chat = MChat(document: snapshot) else {
                completion(.failure(FirestoreError.fetchDocumentError))
                return
            }
            completion(.success(chat))
        }
        return chatListener
    }
}
