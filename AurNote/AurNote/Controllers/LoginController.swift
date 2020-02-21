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

@objc(LoginController)
class LoginController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(LoginController.receiveToggleAuthUINotification(_:)),
            name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil)

        statusText.text = "Initialized Swift app..."
        toggleAuthUI()
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
               // [START_EXCLUDE silent]
               statusText.text = "Signed out."
               toggleAuthUI()
               // [END_EXCLUDE]
    }
    
    @IBAction func didTapDisconnect(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().disconnect()
        // [START_EXCLUDE silent]
        statusText.text = "Disconnecting."
        // [END_EXCLUDE]
    }
    
    // [START toggle_auth]
    func toggleAuthUI() {
      if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
        // Signed in
        signInButton.isHidden = false
        signOutButton.isHidden = false
        disconnectButton.isHidden = false
      } else {
        signInButton.isHidden = false
        signOutButton.isHidden = true
        disconnectButton.isHidden = true
        statusText.text = "Google Sign in\niOS Demo"
      }
    }
    // [END toggle_auth]
    
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
        self.toggleAuthUI()
        if notification.userInfo != nil {
          guard let userInfo = notification.userInfo as? [String:String] else { return }
          self.statusText.text = userInfo["statusText"]!
        }
      }
    }
}
