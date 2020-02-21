//
//  SecondViewController.swift
//  AurNote
//
//  Created by Ayush Patel on 2/16/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoggedInViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("here")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        statusText.text = "Signed out."
    }


}

