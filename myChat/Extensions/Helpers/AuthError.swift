//
//  AuthError.swift
//  myChat
//
//  Created by QwertY on 03.09.2022.
//

import Foundation

enum AuthError {
    case notFilled
    case invalidEmail
    case passwordsNotMatched
    case unknownError
    case serverError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Fill all fields!", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Wrong email format!", comment: "")
        case .passwordsNotMatched:
            return NSLocalizedString("Passwords do not matched", comment: "")
        case .unknownError:
            return NSLocalizedString("Oops! Unknown error!", comment: "")
        case .serverError:
            return NSLocalizedString("Server error! We are working on it!", comment: "")
        }
    }
}
