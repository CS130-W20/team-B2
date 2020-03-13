//
//  NoteManagementController.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/19/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit



/// Represents each of the user's folders contains only a label for the folder name
class DirectoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var directoryName: UILabel!
    @IBOutlet weak var directoryName2: UILabel!
    /// sets the  cell's name to the name of the folder
    /// - Parameter name: String name of the folder
    func displayContent(name: String) {
        var localCopy = name.split(separator: " ")
        let courseNumber = localCopy.popLast()
        directoryName2.text = String(courseNumber!)
        directoryName.text = localCopy.joined(separator: " ");
        
    }
}

class AddFolderCell: UICollectionViewCell {
    @IBOutlet weak var addFolderImage: UIImageView!
    @IBOutlet weak var addFolderLabel: UILabel!
    
    func displayContent() {
        addFolderImage.image = UIImage(named: "add-folder")
        addFolderLabel.text = "Add Folder"
    }
    
}

class SharedFolderCell: UICollectionViewCell {

    @IBOutlet weak var sharedFolderImage: UIImageView!
    @IBOutlet weak var sharedFolderLabel: UILabel!
    func displayContent() {
        sharedFolderImage.image = UIImage(named: "Shared Icon")
        sharedFolderLabel.text = "SHARED"
    }
}

/// The view controller for the splash page which includes collection view
class NoteManagementController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    static let searchUpdate = Notification.Name("searchUpdate")
    var data = [String]()
    var userId: String = ""       //change this to dynamically obtain signed in userId
    var awsBucketHandler: AWSBucketHandler? = nil
    var newFolder:UITextField = UITextField()
    var search = UISearchController(searchResultsController: nil)

    @IBOutlet weak var directoryCollection: UICollectionView!
    
    ///overrides function so the bucket handler is initialized and the names of the directories are recieved
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.search.searchBar.delegate = self
        self.navigationItem.searchController = search
        
        data = []
        userId = AppDelegate.shared().userId
        awsBucketHandler = AppDelegate.shared().awsBucketHandler
        awsBucketHandler!.initializeUser(completion: { result in
            self.awsBucketHandler!.getAllFiles(completion: { result in
            self.data = self.awsBucketHandler!.getDirectories()
                    self.data.append("shared_w_me")
                    self.data.append("Add Folder")
                    DispatchQueue.main.async {
                        self.directoryCollection.reloadData()
                    }
                })
        })
    }
    
    
    ///sets the datasource after viewDidLoad runs
    /// - Parameter animated: if we want to animate the display
    override func viewDidAppear(_ animated: Bool) {
        filteredResultsView.isHidden = true
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
        let folderName = data[indexPath.row]
        if(folderName == "Add Folder") {
            let cell = directoryCollection.dequeueReusableCell(withReuseIdentifier: "addFolderCell", for: indexPath) as! AddFolderCell
            cell.displayContent()
            cell.layer.masksToBounds = true;
            cell.layer.cornerRadius = 10;
            return cell
        } else if(folderName == "shared_w_me") {
            let cell = directoryCollection.dequeueReusableCell(withReuseIdentifier: "sharedFolderCell", for: indexPath) as! SharedFolderCell
            cell.displayContent()
            cell.layer.masksToBounds = true;
            cell.layer.cornerRadius = 10;
            return cell
        } else {
            let cell = directoryCollection.dequeueReusableCell(withReuseIdentifier: "directoryCollectionCell", for: indexPath) as! DirectoryCollectionCell
            cell.displayContent(name: folderName)
            cell.layer.masksToBounds = true;
            cell.layer.cornerRadius = 10;
            return cell
        }
        
    }
    
    func configurationTextField(textField: UITextField!)
    {
        print("configurat hire the TextField")
        if textField != nil {

            self.newFolder = textField!        //Save reference to the UITextField
            self.newFolder.placeholder = "Folder Name"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(data[indexPath.row] == "Add Folder") {
            let alert = UIAlertController(title: "Create folder", message: "Type in the name of your new folder.", preferredStyle: UIAlertController.Style.alert)

            alert.addTextField(configurationHandler: configurationTextField)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                print("User clicked Cancel button")
            }))

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
                print("User click Ok button")
                let newFolderName = self.newFolder.text
                self.awsBucketHandler?.putDirectory(folderName: newFolderName!, completion: {result in
                    if(result != nil) {
                        self.data.insert(newFolderName!, at: self.data.count-1)
                        DispatchQueue.main.async {
                             self.directoryCollection.reloadData()
                         }
                    } else {
                        print("Error putting directory")
                    }
                })
            }))

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        }
    }
    
    
    @IBOutlet weak var filteredResultsView: UIView!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Add your search logic here
        print(searchText)
        //var matchingFilenames = [(String, String)]()
        //an array of all (foldername, filename) tuples that contained this word
        let matchingFilenames = handwriting.allText[searchText.lowercased()]
        var matchingImages = [(String, UIImage)]()
        print(matchingFilenames)
        if (matchingFilenames != nil){
            for (_, file) in matchingFilenames!{
                matchingImages.append((file, awsBucketHandler!.fileMap[file]!))
            }
        }
        NotificationCenter.default.post(name: NoteManagementController.searchUpdate, object: nil, userInfo:["data": matchingImages])
        //handwriting.allText[searchText.lowercased()].0
        if (searchText.count > 0) {
            directoryCollection.isHidden = true
        }
        else {
            directoryCollection.isHidden = false
        }

        
        // you can use this to show the view
        // the view controller is in Search.storyboard
        filteredResultsView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredResultsView.isHidden = true
        directoryCollection.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FileDisplayViewController {
            let vc = segue.destination as? FileDisplayViewController
            vc?.awsBucketHandler = self.awsBucketHandler
            vc?.userId = self.userId
            vc?.folderName = self.data[(directoryCollection.indexPathsForSelectedItems?.last!.row)!]
        } else if (segue.destination is SharedFoldersViewController) {
            let vc = segue.destination as? SharedFoldersViewController
            vc?.awsBucketHandler = self.awsBucketHandler
            vc?.userId = self.userId
        }
    }
    
}
