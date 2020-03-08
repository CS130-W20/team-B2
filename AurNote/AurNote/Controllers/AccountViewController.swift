//
//  AccountViewController.swift
//  AurNote
//
//  Created by Ayush Patel on 3/7/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import GoogleSignIn

class AccountViewController: UIViewController {
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
//        self.performSegue(withIdentifier: "logoutSuccessful", sender: nil)
    }
}
