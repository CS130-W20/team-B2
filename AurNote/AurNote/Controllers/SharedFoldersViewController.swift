//
//  SharedFoldersViewController.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 3/4/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit

class SharedCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var sharedFolderName: UILabel!
    @IBOutlet weak var usersName: UILabel!
    
    /// sets the  cell's name to the name of the folder
    /// /// - Parameter name: String name of the folder
    func displayContent(name: String) {
        var localCopy = name.split(separator: "/")
        let fn = localCopy.popLast()
        sharedFolderName.text = String(fn!)
        usersName.text = localCopy.joined(separator: " ");
    }
}

class SharedFoldersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var data = [String]()
    var userId = AppDelegate.shared().userId         //change this to dynamically obtain signed in userId
    var awsBucketHandler: AWSBucketHandler? = nil
    
    @IBOutlet weak var sharedCollection: UICollectionView!
    
    ///overrides function so the bucket handler is initialized and the names of the directories are recieved
    override func viewDidLoad() {
        super.viewDidLoad()
        data = awsBucketHandler!.getSharedDirectories()
        DispatchQueue.main.async {
            self.sharedCollection.reloadData()
        }
    }
    
    
    ///sets the datasource after viewDidLoad runs
    /// - Parameter animated: if we want to animate the display
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("TabBarToggle"), object: nil, userInfo: ["isHidden": true])
        view.addSubview(sharedCollection)
        sharedCollection.delegate = self
        sharedCollection.dataSource = self
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
//        let width = (view.frame.size.width - 10)/3
//        let layout = sharedCollection.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: width, height: width)
        let fName = data[indexPath.row]
        let cell = sharedCollection.dequeueReusableCell(withReuseIdentifier: "sharedCollectionCell", for: indexPath) as! SharedCollectionCell
        cell.displayContent(name: fName)
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 10;
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FileDisplayViewController {
            let vc = segue.destination as? FileDisplayViewController
            vc?.awsBucketHandler = self.awsBucketHandler
            vc?.userId = self.userId
            vc?.folderName = self.data[(sharedCollection.indexPathsForSelectedItems?.last!.row)!]
            vc?.isShared = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("TabBarToggle"), object: nil, userInfo: ["isHidden": false])
    }

}
