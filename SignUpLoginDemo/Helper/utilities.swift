//
//  File.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 19/10/21.
//

import Foundation
import UIKit
class utilities {
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[0-9])(?=.*[A-Z])(?=.*[@#$%^&+=]).{8,}$")
        return passwordTest.evaluate(with: password)
    }
    static func isEmailValid(_ email : String) -> Bool {
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@","^[a-zA-z0-9]+?(.)[a-zA-Z0-9+_-]*@[a-zA-Z]+\\.[a-zA-z]{2,4}?(.)[A-za-z]*$")
        return emailTest.evaluate(with: email)
    }
    
}

