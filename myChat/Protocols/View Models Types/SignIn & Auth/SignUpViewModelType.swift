//
//  SignUpViewModelType.swift
//  myChat
//
//  Created by QwertY on 20.09.2022.
//

import Foundation
import FirebaseAuth

protocol SignUpViewModelType {
    
    var user: User? { get }
    var setupProfileVC: SetupProfileViewController? { get }
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping(Result<Void, Error>) -> Void)
}
