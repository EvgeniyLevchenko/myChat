//
//  MMessage.swift
//  myChat
//
//  Created by QwertY on 12.09.2022.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct MMessage: Hashable, MessageType {
    let content: String
    var sender: SenderType
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageItem(placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: MUser, content: String) {
        self.content = content
        sender = Sender(senderId: user.id, displayName: user.username)
        sentDate = Date()
        id = nil
    }
    
    init(user: MUser, image: UIImage) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        if let sentDate = data["created"] as? Timestamp {
            self.sentDate = sentDate.dateValue()
            print("sent date error")
        } else {
            self.sentDate = Date()
        }
        guard let senderID = data["senderID"] as? String else {
            print("sender id error")
            return nil
        }
        guard let senderUsername = data["senderUsername"] as? String else {
            print("sender username error")
            return nil
        }
        
        self.id = document.documentID
        sender = Sender(senderId: senderID, displayName: senderUsername)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderUsername": sender.displayName,
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
