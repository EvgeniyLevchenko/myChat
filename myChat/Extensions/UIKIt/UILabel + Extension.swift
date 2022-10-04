//
//  UILabel + Extension.swift
//  myChat
//
//  Created by QwertY on 12.08.2022.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
}
