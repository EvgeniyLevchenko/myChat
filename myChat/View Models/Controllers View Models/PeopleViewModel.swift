//
//  PeopleViewModel.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PeopleViewModel: PeopleViewModelType {
    
    var currentUser: MUser
    var users: Box<[MUser]> = Box([])
    var usersListener: ListenerRegistration?
    
    required init(currentUser: MUser) {
        self.currentUser = currentUser
    }
    
    func reloadDataSource(with searchText: String? = nil, completion: @escaping (NSDiffableDataSourceSnapshot<UserSection, MUser>) -> Void) {
        let filtered = users.value.filter { user in
            user.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<UserSection, MUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)
        completion(snapshot)
    }
    
    func createUsersObserver(completion: @escaping (Error?) -> Void) {
        usersListener = ListenerService.shared.usersObserve(users: users.value, completion: { result in
            switch result {
            case .success(let users):
                self.users.value = users
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func signOut(from view: UIView, completion: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let signOutAction = UIAlertAction(title: "Sign out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                view.window?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        completion(alertController)
    }
}
