//
//  AuthViewModel.swift
//  myChat
//
//  Created by QwertY on 18.09.2022.
//

import UIKit
import FirebaseAuth

class AuthViewModel: AuthViewModelType {
    var mUser: MUser?
    var user: User?
    
    lazy var loginVC: LoginViewController = LoginViewController(delegate: self as AuthNavigationDelegate)
    lazy var signUpVC: SignUpViewController = SignUpViewController(delegate: self as AuthNavigationDelegate)
    
    lazy var mainTabBarVC: MainTabBarController? = {
        guard let mUser = mUser else { return nil }
        return MainTabBarController(currentUser: mUser)
    }()
    
    lazy var setupProfileVC: SetupProfileViewController? =  {
        guard let user = user else { return nil }
        let viewModel = SetupProfileViewModel(currentUser: user)
        return SetupProfileViewController(viewModel: viewModel)
    }()
    
    func googleLogin(presentingVC viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        AuthService.shared.googleLogin(presentingVC: viewController) { result in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):
                        self.mUser = mUser
                        completion(.success(Void()))
                    case .failure(_):
                        self.user = user
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func toLoginVC() {
        let topVC = UIApplication.topViewController()
        topVC?.present(loginVC, animated: true)
    }
    
    func toSignUpVC() {
        let topVC = UIApplication.topViewController()
        topVC?.present(signUpVC, animated: true)
    }
}
