//
//  MenuViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 25/10/21.
//

import UIKit
import FBSDKLoginKit

class MenuViewController: UITableViewController {
    
    var menuItems = ["Home","Profile","Archieve","Reminder","Logout"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuCell
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menuItems[indexPath.row] == "Logout" {
            do {
                NetworkManager.shared.signout()
                NetworkManager.shared.googleSignOut()
                LoginManager.init().logOut()
                transitionToLogin()
            } catch {
                showAlert(title: "Error", message: "error in signing out")
                return
            }
        }
        if menuItems[indexPath.row] == "Profile" {
            let profileController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileController.modalPresentationStyle = .fullScreen
            present(profileController,animated: true,completion: nil)
        }
        
        if menuItems[indexPath.row] == "Archieve" {
            let archieveController = storyboard?.instantiateViewController(withIdentifier: "ArchieveViewController") as! ArchieveViewController
            archieveController.modalPresentationStyle = .fullScreen
            present(archieveController,animated: true,completion: nil)
        }
        
        if menuItems[indexPath.row] == "Reminder" {
            let archieveController = storyboard?.instantiateViewController(withIdentifier: "RemindViewController") as! RemindViewController
            archieveController.modalPresentationStyle = .fullScreen
            present(archieveController,animated: true,completion: nil)
        }
        
        
        
    }
    
    func transitionToLogin() {
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "SigninVC")
        
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
}
