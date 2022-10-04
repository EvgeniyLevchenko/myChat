//
//  WaitingChatNavigation.swift
//  myChat
//
//  Created by QwertY on 13.09.2022.
//

import Foundation

protocol WaitingChatNavigation: AnyObject {
    func removeWaitingChat(chat: MChat)
    func chatToActive(chat: MChat)
}
