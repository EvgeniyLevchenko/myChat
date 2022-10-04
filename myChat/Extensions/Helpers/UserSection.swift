//
//  UserSection.swift
//  myChat
//
//  Created by QwertY on 22.09.2022.
//

import Foundation

enum UserSection: Int, CaseIterable {
    case users
    
    func description(usersCount: Int) -> String {
        switch self {
        case .users:
            return "\(usersCount) people nearby"
        }
    }
}
