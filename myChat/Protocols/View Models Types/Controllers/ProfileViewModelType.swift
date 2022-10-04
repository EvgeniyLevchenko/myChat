//
//  ProfileViewModelType.swift
//  myChat
//
//  Created by QwertY on 23.09.2022.
//

import UIKit

protocol ProfileViewModelType {
    var user: MUser { get }
    var username: Box<String> { get }
    var description: Box<String> { get }
    var avatarStringURL: Box<String> { get }
    
    init(user: MUser)
    
    func setImage(completion: @escaping (UIImage?) -> Void)
    func sendMessage(message: String, completion: @escaping (Error?) -> Void)
}
