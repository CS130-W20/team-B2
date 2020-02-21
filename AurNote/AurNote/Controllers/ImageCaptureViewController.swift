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

class ImageCaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // TODO: create dictionary to store set of codes ?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        imagePicker.allowsEditing = true
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
        
        let code = randomString(length: 6)
        print(code)
        store(image: image, forKey: code, withStorageType: StorageType.fileSystem)
        
//         example of retrieving and displaying saved image
        DispatchQueue.global(qos: .background).async {
            if let savedImage = self.retrieveImage(forKey: code, inStorageType: StorageType.fileSystem) {
                DispatchQueue.main.async {
                    self.savedImage.image = savedImage
                }
            }
        }
        codeMessage.text = String(code)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    /// stores image and associates it with a code
    /// - Parameters:
    ///  - image: image to be stored
    ///  - key: code to associate with the image
    ///  - storageType: type of storage (filesystem or other)
    private func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                // save to disk
                if let filePath = filePath(forKey: key) {
                    do {
                        try pngRepresentation.write(to: filePath, options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                //save to user defaults
                UserDefaults.standard.set(pngRepresentation, forKey: key)
            }
        }
    }
    
    /// retrieves image from the user's filesystem based on given code
    /// - Parameters:
    ///  - key: code associated with the desired image
    ///  - storageType: type of storage (filesystem or other)
    private func retrieveImage(forKey key: String, inStorageType storageType: StorageType) -> UIImage? {
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
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            return nil
        }
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    /// - Parameter length: the length of the random string you want to generate
    /// generates a random string of specified length to be used as a code
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
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
