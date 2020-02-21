//
//  NoteManagementController.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/19/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3

/// Represents each of the user's folders contains only a label for the folder name
class DirectoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var directoryName: UILabel!
    /// sets the  cell's name to the name of the folder
    /// - Parameter name: String name of the folder
    func displayContent(name: String) {
        directoryName.text = name;
    }
}

/// The view controller for the splash page which includes collection view
class NoteManagementController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var data = [String]()
    let userId = "testUser"         //change this to dynamically obtain signed in userId
    var awsBucketHandler: AWSBucketHandler? = nil
    

    @IBOutlet weak var directoryCollection: UICollectionView!
    
    ///overrides function so the bucket handler is initialized and the names of the directories are recieved
    override func viewDidLoad() {
        super.viewDidLoad()
        data = []
        let awsBucketHandler = AWSBucketHandler(id: userId)
        awsBucketHandler.getAllFiles(completion: {result in
            if(result != nil) {
                self.data = awsBucketHandler.getDirectories()
                self.data.append("Add Folder")
            } else {
                print("Error in getting files")
            }
        })
    
        
    }
    
    ///sets the datasource after viewDidLoad runs
    /// - Parameter animated: if we want to animate the display
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(directoryCollection)
        directoryCollection.delegate = self
        directoryCollection.dataSource = self
    }
    
    ///Tells the controller how many cells to display
    /// - Parameters:
    ///   - collectionView: UICollectionView the collection view on the controller
    ///   - section: Int the number of sections in the controller
    /// - Return: Int: the number of cells needed in the view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    ///sets content of each cell from data array and styles cells
    /// - Parameters:
    ///   - collectionView: UICollectionView the collection view on the controller
    ///   - indexPath: IndexPath gets the cell that we want to modify
    /// - Return: UICollectionViewCell: the formatted collection view cell to add to the view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = (view.frame.size.width - 10)/3
        let layout = directoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        let cell = directoryCollection.dequeueReusableCell(withReuseIdentifier: "directoryCollectionCell", for: indexPath) as! DirectoryCollectionCell
        cell.displayContent(name: data[indexPath.row])
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 10;
        return cell
    }
    
}
