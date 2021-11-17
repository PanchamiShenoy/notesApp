//
//  ViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 18/10/21.
//

import UIKit

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
class ViewController: UIViewController{
    
    @IBOutlet weak var button1: FBLoginButton!
    let signInConfig = GIDConfiguration.init(clientID: "270094336120-eohpmqe1l4ghvre5b6s4k2sm3h0nr7e9.apps.googleusercontent.com")
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let token = AccessToken.current,
           !token.isExpired {
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            transitionToHome()
        }
        else{
            button1.permissions = ["public_profile", "email"]
            button1.delegate = self
            
        }
        let status = NetworkManager.shared.checkSignIn()
        if(status == true){
            self.transitionToHome()
        }
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                
            }
            else{
                self.transitionToHome()
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showAlert(title: "Error", message: "Please fill all the fields")
            return
        }
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        NetworkManager.shared.login(withEmail: email, password: password){ [weak self] result, error in
            if error != nil {
                self!.showAlert(title: "Error", message: "Error while Signing In")
            }
            else{
                self!.transitionToHome()
            }
        }
    }
    
    @IBAction func onGoogleSignIn(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                showAlert(title: "Error", message: "")
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let authError = error as NSError
                    print(error.localizedDescription)
                    print(authError)
                }
                else {
                    transitionToHome()
                }
            }
            
        }
    }
    
}

extension ViewController :LoginButtonDelegate{
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        if token != "" {
            transitionToHome()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier:"ContainerViewController")
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}

