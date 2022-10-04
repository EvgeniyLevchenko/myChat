//
//  ChatSection.swift
//  myChat
//
//  Created by QwertY on 22.09.2022.
//

import Foundation

enum ChatSection: Int, CaseIterable {
    case waitingChats, activeChats
    
    func description() -> String {
        switch self {
        case .waitingChats:
            return "Waiting Chats"
        case .activeChats:
            return "Active Chats"
        }
    }
}
