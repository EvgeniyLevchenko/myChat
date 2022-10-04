//
//  ListViewModel.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseFirestore

class ListViewModel: ListViewModelType {

    var currentUser: MUser
    var activeChats: [MChat] = []
    var waitingChats: [MChat] = []
    var waitingChatsListener: ListenerRegistration?
    var activeChatsListener: ListenerRegistration?
    var chatRequestVC: ChatRequestViewController?
    
    var isWaitingChatsEmpty: Bool {
        return waitingChats.isEmpty
    }
    
    required init(currentUser: MUser) {
        self.currentUser = currentUser
    }
    
    func reloadDataSource(completion: @escaping (NSDiffableDataSourceSnapshot<ChatSection, MChat>) -> Void) {
        var snapshot = NSDiffableDataSourceSnapshot<ChatSection, MChat>()
        snapshot.appendSections([.waitingChats])
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendSections([.activeChats])
        snapshot.appendItems(activeChats, toSection: .activeChats)
        completion(snapshot)
    }
    
    func createWaitingChatsObserver(completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats) { result in
            switch result {
            case .success(let chats):
                if self.waitingChats != [], self.waitingChats.count <= chats.count {
                    guard let waitingChat = chats.last else {
                        completion(.failure(FirestoreError.noChatsError))
                        return
                    }
                    let chatRequestViewModel = ChatRequestViewModel(chat: waitingChat)
                    self.chatRequestVC = ChatRequestViewController(viewModel: chatRequestViewModel)
                }
                self.waitingChats = chats
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createActiveChatsObserver(completion: @escaping (Result<Void, Error>) -> Void) {
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats) { result in
            switch result {
            case .success(let activeChats):
                self.activeChats = activeChats
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeListeners() {
        waitingChatsListener?.remove()
        activeChatsListener?.remove()
    }
}

extension ListViewModel: WaitingChatNavigation {
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { error in
            if let error = error {
                let topVC = UIApplication.topViewController()
                topVC?.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
    }
    
    func chatToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { error in
            if let error = error {
                let topVC = UIApplication.topViewController()
                topVC?.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
    }
}
