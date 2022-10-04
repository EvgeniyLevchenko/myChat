//
//  SignUpViewModel.swift
//  myChat
//
//  Created by QwertY on 20.09.2022.
//

import UIKit
import FirebaseAuth

class SignUpViewModel: SignUpViewModelType {
    
    var user: User?
    
    lazy var setupProfileVC: SetupProfileViewController? = {
        guard let user = user else { return nil }
        let viewModel = SetupProfileViewModel(currentUser: user)
        return SetupProfileViewController(viewModel: viewModel)
    }()
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        AuthService.shared.register(email: email, password: password, confirmPassword: confirmPassword) { result in
            switch result {
            case .success(let user):
                self.user = user
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
