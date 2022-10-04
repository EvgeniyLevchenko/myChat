//
//  FirestoreError.swift
//  myChat
//
//  Created by QwertY on 14.09.2022.
//

import Foundation

enum FirestoreError {
    case fetchDocumentError
    case documentIdError
    case documentIsEmpty
    case noDocumentsError
    case noMessageError
    case noChatsError
    case unknown
}

extension FirestoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchDocumentError:
            return NSLocalizedString("Error occured while fetching decuments.", comment: "")
        case .documentIdError:
            return NSLocalizedString("Document ID error.", comment: "")
        case .documentIsEmpty:
            return NSLocalizedString("Document data is empty", comment: "")
        case .noDocumentsError:
            return NSLocalizedString("Documents error.", comment: "")
        case .noMessageError:
            return NSLocalizedString("Message error.", comment: "")
        case .noChatsError:
            return NSLocalizedString("Chats fetching error.", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown error.", comment: "")
        }
    }
}
