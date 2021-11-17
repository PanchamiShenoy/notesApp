//
//  SignUpViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 18/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Signup1ViewController: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var secondNameTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignup(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            showAlert(title: "Error", message:error!)
        }else{
            
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let secondName = secondNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            NetworkManager.shared.signup(withEmail: email, password: password){ [weak self] result, error in
                if error != nil {
                    self!.showAlert(title: "Error", message: "Error while creating user")
                }
                else{
                    let userDetails: [String: Any] = ["firstname": firstName,"lastname":secondName,"uid": result!.user.uid]
                    NetworkManager.shared.writeDocument(documentName: "users",data: userDetails)
                    self!.transitionToHome()
                    
                }
                
            }
        }
    }
    
    func validateFields() -> String? {
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || secondNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please fill in all details"
        }
        let cleanemail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if utilities.isEmailValid(cleanemail) == false {
            return "please enter a valid email "
        }
        let cleanpassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if utilities.isPasswordValid(cleanpassword) == false {
            return "please enter a valid password "
        }
        return nil
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier:"ContainerViewController")
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
}

