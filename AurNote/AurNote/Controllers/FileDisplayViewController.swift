//
//  FileDisplayViewController.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/25/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit

/*global so that the parsed text is available always*/
let handwriting = HandwritingManager()

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

class FileDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var folderLabel: UILabel!
    @IBOutlet weak var fileCollection: UICollectionView!
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    var userId = ""
    var awsBucketHandler: AWSBucketHandler? = nil
    var folderName = ""
    var fileImages = [(String,UIImage)]()
    var email:UITextField = UITextField()
    var imgStore = ImageStorer()
    var isShared = false
    var capturedImage: UIImage?
    
    @IBAction func unwindFromCameraWithFailure(_ sender: UIStoryboardSegue) {
        print("I am back home")
    }
    
    @IBAction func unwindFromCameraWithSuccess(_ sender: UIStoryboardSegue) {
        if sender.source is ARAnnotationViewController {
            if let senderVC = sender.source as? ARAnnotationViewController {
                capturedImage = senderVC.processedImage
                if let unwrappedImage = senderVC.processedImage {
                    uploadToAWS(unwrappedImage)
                }
                //writes to the photo gallery
//                if let unwrappedImage = capturedImage {
//                    UIImageWriteToSavedPhotosAlbum(unwrappedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//                }
            }
        }
    }
    
    //func to write an image to disk
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func uploadToAWS(_ image: UIImage) {
            var code = String()
            while (true) {
                code = imgStore.randomString(length: 10)
                if (imgStore.retrieveImage(forKey: code, inStorageType: ImageStorer.StorageType.fileSystem) == nil) {
                    break
                }
            }
            
            imgStore.store(image: image, forKey: code, withStorageType: ImageStorer.StorageType.fileSystem)
            let fileName = imgStore.randomString(length: 9)
            let filePath = imgStore.filePath(forKey: code)
            print(code, fileName, folderName)
        
            /*before uploading, also parse for words*/
            handwriting.processImage(uiImage: image, className: folderName, fileName: fileName)
        
            awsBucketHandler?.putFile(folderName: folderName, fileName: fileName, fileURL: filePath!, completion: {result in
                if(result != nil) {
                    print("file added")
                    self.fileImages = (self.awsBucketHandler?.returnFilesInDirectory(folderName: self.folderName))!
                    DispatchQueue.main.async {
                        self.fileCollection.reloadData()
                    }
                } else {
                    print("Error in file display controller")
                }
            })
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        folderLabel.text = folderName
        if(self.isShared == true) {
            shareBtn.isEnabled = false
            addBtn.isEnabled = false
            
            awsBucketHandler?.getFilesInSharedDirectory(folderName: folderName, completion: {
                result in
                if(result != nil) {
                    self.fileImages = (self.awsBucketHandler?.returnFilesInDirectory(folderName: self.folderName))!
                    DispatchQueue.main.async {
                        self.fileCollection.reloadData()
                    }
                    
                } else {
                    print("Error in file display controller")
                }
            })
            
        } else {
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

            shareBtn.target = self
            shareBtn.action = #selector(shareAction)
        }
        view.addSubview(fileCollection)
        fileCollection.delegate = self
        fileCollection.dataSource = self

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
