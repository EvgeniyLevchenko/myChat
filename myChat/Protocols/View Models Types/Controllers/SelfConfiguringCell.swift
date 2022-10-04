//
//  SelfConfiguringCell.swift
//  myChat
//
//  Created by QwertY on 23.08.2022.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseID: String { get }
    func configure<U: Hashable>(with value: U)
}
