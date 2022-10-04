//
//  AuthService.swift
//  myChat
//
//  Created by QwertY on 03.09.2022.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    func login(email: String?, password: String?, completion: @escaping(Result<User, Error>) -> Void) {
        
        guard let email = email,
              let password = password
        else {
            completion(.failure(AuthError.notFilled))
            return
        }

        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(AuthError.unknownError))
                }
                
                return
            }
            completion(.success(result.user))
        }
    }
    
    func googleLogin(presentingVC: UIViewController, completion: @escaping(Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingVC) { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                completion(.failure(AuthError.unknownError))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                guard let result = result else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(AuthError.unknownError))
                    }
                    return
                }
                completion(.success(result.user))
            }
        }
    }
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping(Result<User, Error>) -> Void) {
        
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        guard password!.lowercased() == confirmPassword!.lowercased() else {
            completion(.failure(AuthError.passwordsNotMatched))
            return
        }
        
        guard Validators.isSimpleEmail(email!) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        auth.createUser(withEmail: email!, password: password!) { result, error in
            guard let result = result else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(AuthError.unknownError))
                }
                return
            }
            completion(.success(result.user))
        }
    }
}
