//
//  FileDisplayViewController.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/25/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit

class FileCollectionCell: UICollectionViewCell {

    @IBOutlet weak var fileImage: UIImageView!
    @IBOutlet weak var fileLabel: UILabel!
    
    /// sets the  cell's name to the name of the folder
    /// - Parameter name: String name of the folder
    func displayContent(name: String, img: UIImage) {
        fileLabel.text = name
        fileImage.image = img
    }
    
}

class FileDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var folderLabel: UILabel!
    @IBOutlet weak var fileCollection: UICollectionView!
    
    @IBOutlet weak var addFileBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    var userId = ""
    var awsBucketHandler: AWSBucketHandler? = nil
    var folderName = ""
    var fileImages = [(String,UIImage)]()
    var email:UITextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderLabel.text = folderName
        awsBucketHandler?.getFilesInDirectory(folderName: folderName, completion: {result in
            if(result != nil) {
                self.fileImages = (self.awsBucketHandler?.returnFilesInDirectory(folderName: self.folderName))!
                DispatchQueue.main.async {
                    self.fileCollection.reloadData()
                }
                
            } else {
                print("Error in file display controller")
            }
        })
        view.addSubview(fileCollection)
        fileCollection.delegate = self
        fileCollection.dataSource = self

        shareBtn.target = self
        shareBtn.action = #selector(shareAction)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fileCollection.reloadData()
    }
    
    ///Tells the controller how many cells to display
    /// - Parameters:
    ///   - collectionView: UICollectionView the collection view on the controller
    ///   - section: Int the number of sections in the controller
    /// - Return: Int: the number of cells needed in the view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileImages.count
    }
    
    ///sets content of each cell from data array and styles cells
    /// - Parameters:
    ///   - collectionView: UICollectionView the collection view on the controller
    ///   - indexPath: IndexPath gets the cell that we want to modify
    /// - Return: UICollectionViewCell: the formatted collection view cell to add to the view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = (view.frame.size.width - 10)/3
        let layout = fileCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        let cell = fileCollection.dequeueReusableCell(withReuseIdentifier: "fileCollectionCell", for: indexPath) as! FileCollectionCell
        cell.displayContent(name: fileImages[indexPath.row].0, img: fileImages[indexPath.row].1)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func configurationTextField(textField: UITextField!)
    {
        print("configure the TextField")
        if textField != nil {

            self.email = textField!        //Save reference to the UITextField
            self.email.placeholder = "Email Address"
        }
    }
    
    @objc func shareAction (sender:UIButton) {
        print("SHARE")
        let alert = UIAlertController(title: "Invite A Collaborator", message: "The collaborator will recieve an email notification and see these files in thier Shared with Me folder.", preferredStyle: UIAlertController.Style.alert)

        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            print("User clicked Cancel button")
        }))

        alert.addAction(UIAlertAction(title: "Invite", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            print("User click Invite button")
            let emailText = self.email.text
            self.awsBucketHandler?.shareFile(folderName: self.folderName, email: emailText! ,completion: {result in
                if(result != nil) {
                    print("File was shared")
                } else {
                    print("Error sharing file")
                }
            })
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}
