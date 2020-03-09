//
//  LoginController.swift
//  AurNote
//
//  Created by Divij Ohri on 2/20/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import GoogleSignIn
import UIKit

@objc(LoginViewController)
class LoginViewController: UIViewController {
    
    @IBAction func googleSignInButton(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func unwindToLoginScreen(segue:UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(LoginViewController.receiveToggleAuthUINotification(_:)),
            name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MainToTimer") {
            let vc = segue.destination as! LoggedInViewController
            vc.statusText.text = "Logged In"
        } else if( segue.identifier == "loginSuccessful") {
            let vc = segue.destination as? NoteManagementController
            vc?.awsBucketHandler = AppDelegate.shared().awsBucketHandler
            vc?.userId = AppDelegate.shared().userId
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return UIStatusBarStyle.lightContent
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self,
          name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
          object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
      if notification.name.rawValue == "ToggleAuthUINotification" {
        self.performSegue(withIdentifier: "loginSuccessful", sender: nil)
      }
    }
}
