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

class DirectoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var directoryName: UILabel!
    func displayContent(name: String) {
        directoryName.text = name;
    }
}

class NoteManagementController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var data = [String]()
    let userId = "testUser"
    var awsBucketHandler: AWSBucketHandler? = nil
    

    @IBOutlet weak var directoryCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = []
        let awsBucketHandler = AWSBucketHandler(id: userId, view: directoryCollection)
        awsBucketHandler.getAllFiles(completion: {result in
            if(result != nil) {
                self.data = awsBucketHandler.getDirectories()
                self.data.append("Add Folder")
            } else {
                print("Error in getting files")
            }
        })
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(directoryCollection)
        directoryCollection.delegate = self
        directoryCollection.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
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
