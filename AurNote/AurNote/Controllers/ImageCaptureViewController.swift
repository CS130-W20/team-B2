/*
Abstract:
A view controller that allows users to upload photos to the app and receive image overlay codes for them.
*/

//
//  ImageCaptureViewController.swift
//  AurNote
//
//  Created by Brandon Oestereicher on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import UIKit
import AVKit
import CropViewController

/// Holds the logic for opening the camera and photo library as well as permissions associated with access to these
class ImageCaptureViewController: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // TODO: create dictionary to store set of codes ?
    var imgStore = ImageStorer()
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera(self)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: presentCamera()
        case .restricted, .denied: alertCameraAccessNeeded()
        @unknown default:
            return
        }
    }
    @IBAction func openPhotoLibrary(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var codeMessage: UILabel!
    
    /// requests user's permission to access their camera
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else {return}
            self.presentCamera()
        })
    }
    
    /// opens the camera
    func presentCamera() {
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .camera
        photoPicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        photoPicker.allowsEditing = false // for now, want to be able to crop in the future
        photoPicker.modalPresentationStyle = .currentContext
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    /// alerts the user that they have not given access to the camera
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        let alert = UIAlertController(title: "Need Camera Access", message: "Camera access needed to make full use of this app", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: {(alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true)
    }
    
    /// takes the image passed from either the camera or the Photo Library,
    /// generates a code for it, and stores it according to that code
    /// - Parameters:
    ///  - picker: source that picked the image
    ///  - info: photo data

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage!
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = img
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = img
        }
        
                var code = String()
                while (true) {
                    code = imgStore.randomString(length: 4)
                    if (imgStore.retrieveImage(forKey: code, inStorageType: ImageStorer.StorageType.fileSystem) == nil) {
                        break
                    }
                }
        //        print(code)
                imgStore.store(image: image, forKey: code, withStorageType: ImageStorer.StorageType.fileSystem)
                
        //         example of retrieving and displaying saved image
                DispatchQueue.global(qos: .background).async {
                    if let savedImage = self.imgStore.retrieveImage(forKey: code, inStorageType: ImageStorer.StorageType.fileSystem) {
                        DispatchQueue.main.async {
                            self.savedImage.image = savedImage
                        }
                    }
                }
                codeMessage.text = String(code)
        
        picker.dismiss(animated: false, completion: {
//            let cropViewController = CropViewController(image: image)
//            cropViewController.delegate = self
//            self.present(cropViewController, animated: false, completion: nil)
        })
        
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - cropViewController: the view controller that is used to crop images
    ///   - image: the newly cropped version of the original image
    ///   - cropRect: the rectangle defined to crop the original image
    ///   - angle: the angle at which the image is rotated
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
                
                var code = String()
                while (true) {
                    code = imgStore.randomString(length: 4)
                    if (imgStore.retrieveImage(forKey: code, inStorageType: ImageStorer.StorageType.fileSystem) == nil) {
                        break
                    }
                }
        //        print(code)
                imgStore.store(image: image, forKey: code, withStorageType: ImageStorer.StorageType.fileSystem)
                
        //         example of retrieving and displaying saved image
                DispatchQueue.global(qos: .background).async {
                    if let savedImage = self.imgStore.retrieveImage(forKey: code, inStorageType: ImageStorer.StorageType.fileSystem) {
                        DispatchQueue.main.async {
                            self.savedImage.image = savedImage
                        }
                    }
                }
                codeMessage.text = String(code)
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

/// Class that handles the storage and retrieval of images in using the user's filesystem. This is for persistent storage of photos. Currently the primary use is for photos that are meant to be overlaid onto notes.
class ImageStorer {
    
    /// Defines possible persistent storage types for photos. Currently only fileSystem is used.
    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    /// stores image and associates it with a code
    /// - Parameters:
    ///  - image: image to be stored
    ///  - key: code to associate with the image
    ///  - storageType: type of storage (filesystem or other)
    func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
        if let jpegRepresentation = image.jpegData(compressionQuality: 1.0) {
            switch storageType {
            case .fileSystem:
                // save to disk
                if let filePath = filePath(forKey: key) {
                    do {
                        try jpegRepresentation.write(to: filePath, options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                //save to user defaults
                UserDefaults.standard.set(jpegRepresentation, forKey: key)
            }
        }
    }
    
    /// retrieves image from the user's filesystem based on given code
    /// - Parameters:
    ///  - key: code associated with the desired image
    ///  - storageType: type of storage (filesystem or other)
    func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            // Retrieve image from disk
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case .userDefaults:
            // Retrieve image from user defaults
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        return nil
    }
    
    /// helper function that gets the filepath for an image based on its code
    /// - Parameter key: code associated with the desired image
    func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            return nil
        }
        return documentURL.appendingPathComponent(key + ".jpeg")
    }
    
    /// - Parameter length: the length of the random string you want to generate
    /// generates a random string of specified length to be used as a code
    func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
