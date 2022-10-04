//
//  Validators.swift
//  myChat
//
//  Created by QwertY on 03.09.2022.
//

import UIKit

class Validators {
    
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let email = email,
              let password = password,
              let confirmPassword = confirmPassword,
              email.isEmpty == false,
              password.isEmpty == false,
              confirmPassword.isEmpty == false
        else {
            return false
        }
        return true
    }
    
    static func isFilled(avatarImage: UIImage?, username: String?, description: String?, sex: String?) -> Bool {
        guard let avatarImage = avatarImage,
              let username = username,
              let description = description,
              let sex = sex,
              avatarImage != UIImage(named: "avatar"),
              username.isEmpty == false,
              description.isEmpty == false,
              sex.isEmpty == false
        else {
            return false
        }
        return true
    }
    
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegEx)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
}
