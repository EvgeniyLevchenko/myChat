//
//  AuthViewModelType.swift
//  myChat
//
//  Created by QwertY on 18.09.2022.
//

import UIKit
import FirebaseAuth

protocol AuthViewModelType: AuthNavigationDelegate {
    
    var mUser: MUser? { get set }
    var user: User? { get set }
    var loginVC: LoginViewController { get }
    var signUpVC: SignUpViewController { get }
    var mainTabBarVC: MainTabBarController? { get }
    var setupProfileVC: SetupProfileViewController? { get }
    func googleLogin(presentingVC viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
}
