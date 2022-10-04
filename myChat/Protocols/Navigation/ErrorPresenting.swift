//
//  ErrorPresenting.swift
//  myChat
//
//  Created by QwertY on 27.09.2022.
//

import Foundation

protocol ErrorPresentingDelegate: AnyObject {
    func presentError(error: Error)
}
