//
//  PeopleViewModelType.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseFirestore

protocol PeopleViewModelType {
    
    var currentUser: MUser { get }
    var users: Box<[MUser]> { get }
    var usersListener: ListenerRegistration? { get }
    
    init(currentUser: MUser)
    
    func reloadDataSource(with searchText: String?, completion: @escaping (NSDiffableDataSourceSnapshot<UserSection, MUser>) -> Void)
    func createUsersObserver(completion: @escaping (Error?) -> Void)
    func signOut(from view: UIView, completion: @escaping (UIAlertController) -> Void)
}
