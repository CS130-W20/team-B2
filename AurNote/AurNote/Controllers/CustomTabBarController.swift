//
//  CustomTabBarController.swift
//  AurNote
//
//  Created by Ayush Patel on 3/8/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tabBarView: UIView!
    
    var noteManagementViewController: UIViewController!
    var imageCaptureViewController: UIViewController!
    var accountViewController: UIViewController!
    
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        let NoteManagementStoryboard = UIStoryboard(name: "NoteManagement", bundle: nil)
        let ImageCaptureStoryboard = UIStoryboard(name: "ImageCapture", bundle: nil)
        
        noteManagementViewController = NoteManagementStoryboard.instantiateViewController(withIdentifier: "NoteManagementViewController")
        imageCaptureViewController = ImageCaptureStoryboard.instantiateViewController(withIdentifier: "ImageCaptureViewController")
        accountViewController = NoteManagementStoryboard.instantiateViewController(withIdentifier: "AccountViewController")
        
        viewControllers = [noteManagementViewController, accountViewController]
        
        buttons[selectedIndex].isSelected = true
        didPressTab(buttons[selectedIndex])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("TabBarToggle"), object: nil)
        
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        buttons[previousIndex].isSelected = false
        let previousVC = viewControllers[previousIndex]
        
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        sender.isSelected = true
        let vc = viewControllers[selectedIndex]
        addChild(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        self.view.sendSubviewToBack(contentView)
        vc.didMove(toParent: self)
    }
    
    @IBAction func didPressCameraButton(_ sender: Any) {
        present(imageCaptureViewController, animated: true, completion: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let UWInfo = notification.userInfo?["isHidden"] as? Bool {
            if UWInfo == true {
                self.tabBarView.isHidden = true
            }
            else {
                self.tabBarView.isHidden = false
            }
        }
    }
    
}
