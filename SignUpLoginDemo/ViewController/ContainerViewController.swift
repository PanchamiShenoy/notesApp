//
//  ContainerViewController.swift
//  SignUpLoginDemo
//
//  Created by Panchami Shenoy on 25/10/21.
//

import UIKit

class ContainerViewController: UIViewController {
    var menuViewController :MenuViewController!
    var centerController :UIViewController!
    var isExpandMenu : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHome()
    }
    
    func configureHome() {
        let home = storyboard!.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
        home.delegate = self
        centerController = UINavigationController(rootViewController: home)
        self.view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    func configureMenu() {
        if menuViewController == nil {
            let storyBoard = UIStoryboard(name:"Main",bundle: nil)
            let menuViewController = storyBoard.instantiateViewController(withIdentifier:"MenuViewController") as! MenuViewController
            //self.view.addSubview(menuViewController.view)
            view.insertSubview(menuViewController.view , at: 0)
            addChild(menuViewController)
            menuViewController.didMove(toParent: self)
            print("menu configure gets call")
        }
    }
    
    func showMenu(isExpand :Bool) {
        if isExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut,animations: {
                self.centerController.view.frame.origin.x = self.centerController.view.frame.width - 80
            }, completion:nil)
            
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut,animations: {
                self.centerController.view.frame.origin.x = 0
            }, completion:nil)
        }
    }
}

extension ContainerViewController :MenuDelegate {
    func menuHandler() {
        print("menu handler get call")
        if !isExpandMenu {
            configureMenu()
        }
        isExpandMenu = !isExpandMenu
        showMenu(isExpand: isExpandMenu)
    }
}
