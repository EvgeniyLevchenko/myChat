//
//  SetupProfileViewModelType.swift
//  myChat
//
//  Created by QwertY on 21.09.2022.
//

import UIKit
import FirebaseAuth

protocol SetupProfileViewModelType: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var currentMUser: MUser? { get }
    var currentUser: User { get }
    var username: String { get }
    var avatarURL: URL? { get }
    var avatarImage: Box<UIImage?> { get }
    var mainTabBarController: MainTabBarController? { get }
    
    init(currentUser: User)

    func saveProfileWith(username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<Void, Error>) -> Void)
}
