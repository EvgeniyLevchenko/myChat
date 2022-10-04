//
//  ListViewModelType.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseFirestore

protocol ListViewModelType {
    
    var currentUser: MUser { get }
    var activeChats: [MChat] { get }
    var waitingChats: [MChat] { get }
    var waitingChatsListener: ListenerRegistration? { get }
    var activeChatsListener: ListenerRegistration? { get }
    var chatRequestVC: ChatRequestViewController? { get }
    var isWaitingChatsEmpty: Bool { get }
    init(currentUser: MUser)
    
    func reloadDataSource(completion: @escaping (NSDiffableDataSourceSnapshot<ChatSection, MChat>) -> Void)
    func createWaitingChatsObserver(completion: @escaping (Result<Void, Error>) -> Void)
    func createActiveChatsObserver(completion: @escaping (Result<Void, Error>) -> Void)
    func removeListeners()
}
