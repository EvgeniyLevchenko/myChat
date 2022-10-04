//
//  LoginViewModelType.swift
//  myChat
//
//  Created by QwertY on 18.09.2022.
//

import UIKit
import FirebaseAuth

protocol LoginViewModelType {
    
    var mUser: MUser? { get set }
    var user: User? { get set }
    var mainTabBarVC: MainTabBarController? { get }
    var setupProfileVC: SetupProfileViewController? { get }
    
    func googleLogin(presentingVC viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
    func login(email: String?, password: String?, completion: @escaping (Result<Void, Error>) -> Void)
}
