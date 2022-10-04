//
//  MChat.swift
//  myChat
//
//  Created by QwertY on 01.09.2022.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    var friendUsername: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var friendID: String
    var isFriendTyping: Bool
    
    var representation: [String : Any] {
        let rep = [
            "friendUsername" : friendUsername,
            "friendAvatarStringURL" : friendAvatarStringURL,
            "lastMessage" : lastMessageContent,
            "friendID" : friendID,
            "isTyping" : isFriendTyping
        ] as [String : Any]
        return rep
    }
    
    init(friendUsername: String, friendAvatarStringURL: String, lastMessageContent: String, friendID: String, isFriendTyping: Bool = false) {
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendID = friendID
        self.isFriendTyping = isFriendTyping
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let friendUsername = data["friendUsername"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendID = data["friendID"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let isFriendTyping = data["isTyping"] as? Bool else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendID = friendID
        self.lastMessageContent = lastMessageContent
        self.isFriendTyping = isFriendTyping
    }
    
    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard let friendUsername = data?["friendUsername"] as? String,
              let friendAvatarStringURL = data?["friendAvatarStringURL"] as? String,
              let friendID = data?["friendID"] as? String,
              let lastMessageContent = data?["lastMessage"] as? String,
              let isFriendTyping = data?["isTyping"] as? Bool else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendID = friendID
        self.lastMessageContent = lastMessageContent
        self.isFriendTyping = isFriendTyping
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendID)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendID == rhs.friendID
    }
}
