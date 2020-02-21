//
//  Login-google.swift
//  AurNote
//
//  Created by Divij Ohri on 2/20/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import GoogleSignIn

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
}
