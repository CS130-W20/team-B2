//
//  SearchViewController.swift
//  AurNote
//
//  Created by Kristi Richter on 3/8/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit

class SearchFileCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var fileImage: UIImageView!
    //    @IBOutlet weak var fileLabel: UILabel!
    /// sets the  cell's name to the name of the folder
    /// - Parameter name: String name of the folder
    func displayContent(name: String, img: UIImage) {
//        fileLabel.isHidden = true
//        fileLabel.text = name
          fileImage.image = img
        
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
}

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var fileCollection: UICollectionView!
    
    var fileImages = [(String,UIImage)]()
    var imgStore = ImageStorer()
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Results"
        
        self.fileCollection.reloadData()
        view.addSubview(fileCollection)
        fileCollection.delegate = self
        fileCollection.dataSource = self

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
        let width = 105
        let layout = fileCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 140)
        let cell = fileCollection.dequeueReusableCell(withReuseIdentifier: "fileCollectionCell", for: indexPath) as! FileCollectionCell
        cell.displayContent(name: fileImages[indexPath.row].0, img: fileImages[indexPath.row].1)
//        cell.layer.masksToBounds = true
//        cell.layer.cornerRadius = 10
//        cell.dropShadow()
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView,
             didSelectItemAt indexPath: IndexPath) {

        let tappedCell = collectionView.cellForItem(at:indexPath) as! FileCollectionCell
        print(tappedCell.fileImage.hashValue)
        
        let newImageView = EEZoomableImageView(image: tappedCell.fileImage.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}
