//
//  AWSBucketHandler.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/20/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import SendGrid_Swift
import UIKit
import AWSCore
import AWSCognito
import AWSS3

/// AWSBucketHandler makes all requests to the S3 bucket using the configuration specified
/// This class is instantiated and passed through many view controllers
class AWSBucketHandler {
    var userId: String
    let myIdentityPoolId = "us-east-2:ef1afe1f-3760-4199-8d9b-e60ba9679866"
    let configuration: AWSServiceConfiguration
    var allFiles = [String]()
    var folderMap = [String: [String]]()
    var s3: AWSS3
    var folderToObjectMap = [String: [(String,UIImage)]]()
    let bucketName = "aurnotecs"
    let sharedFolderName = "shared_w_me"
    var fileMap = [String : UIImage]() //stores filename to UIImage mapping
    let SENDGRID_API_KEY="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"
    let SENDGRID_API_USER = "AuRNote"
    
    
    ///initializes and configures credential provider with userpool id and credentials
    /// - Parameter id: a unique identifier for the logged in user, also the name of their folder in the S3 bucket
    init(id: String) {
        self.userId = id
        
        // initializing credential provider
        let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: myIdentityPoolId)
        configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //register the config
       AWSS3.register(with: configuration, forKey: "defaultKey")
       s3 = AWSS3.s3(forKey: "defaultKey")

    }
    
    public func initializeUser(completion: @escaping (AnyObject?)->()) {
        
        let headObjectsRequest = AWSS3HeadObjectRequest()
        headObjectsRequest!.bucket = bucketName
        headObjectsRequest!.key = userId + "/"
        s3.headObject(headObjectsRequest!).continueWith { (task) -> AnyObject? in
            if task.error != nil {
                print("item does not exist")
                let putRequest = AWSS3PutObjectRequest()
                putRequest?.bucket = self.bucketName
                putRequest?.key = self.userId + "/"
                
                // Start asynchronous upload
                self.s3.putObject(putRequest!).continueWith { (task: AWSTask!) -> AnyObject? in
                    if task.error != nil {
                        print("Error putting")
                        print(task.error.debugDescription)
                    } else {
                        print("Put complete")
                        // upload is complete, set the corresponding member vars
                        self.putDirectory(folderName: self.sharedFolderName, completion: { result in
                            if(result == nil) {
                                print("Did not add shared folder")
                            }
                            completion(result)
                            return
                        })
                    }
                    completion(task)
                    return nil
                }
            }
            completion(true as AnyObject)
            return nil
        }
    }
    
    ///gets the names of all files in the user's directory and stores it in a global variable
    /// - Parameter completion: this is an event callback that lets the caller execute some function after the request completes
    func getAllFiles(completion: @escaping (AnyObject?)->()) {
        
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "aurnotecs"
        listRequest.prefix = userId+"/"

        //make the request and populate data
        print("made request")
        s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
            self.allFiles.removeAll()
            for object in (task.result?.contents)! {
                print("Object key = \(object.key!)")
                self.allFiles.append(object.key!)
            }
            completion(task)
            return nil
        }
    }

    //isolates directory names and returns to caller, ensures non-redundancy
    /// Extracts the list of directories from the file names to populate the splash page of user folders
    /// Return - Array<String> which contains the names of all user folders (unique)
    public func getDirectories() -> Array<String> {
        var data = [String]()
        folderMap.removeAll()
        print("Printing all files:")
        print(allFiles)
        print(folderMap)
        for str in self.allFiles {
            let dir = (String(str.dropFirst(self.userId.count + 1)))
            let slashInd = dir.firstIndex(of: "/")
            if((slashInd) != nil) {
                let dirName = String(dir.prefix(upTo: slashInd!))
                if(folderMap[dirName] != nil) {
                    var temp = String(dir.suffix(from: slashInd!))
                    temp.removeFirst(1)
                    folderMap[dirName]?.append(temp)
                } else {
                    if( dirName != sharedFolderName) {
                        data.append(dirName)
                    }
                    folderMap[dirName] = []
                }
            }
        }
        print(folderMap)
        return data
    }
    
    func getObject(path: String, folderName: String, fileName: String, completion: @escaping (AnyObject?)->()) {
        
        // Hard-coded names for the tutorial bucket and the file uploaded at the beginning
        let dwnPath = path.replacingOccurrences(of: "/", with: "-")
        let downloadFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(dwnPath)

        // Create a new download request to S3, and set its properties
        let downloadRequest = AWSS3GetObjectRequest()
        downloadRequest!.bucket = bucketName
        downloadRequest!.key  = path
        downloadRequest!.downloadingFileURL = downloadFilePath
        
        // Start asynchronous download
        s3.getObject(downloadRequest!).continueWith { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error downloading")
                print(task.error.debugDescription)
            }
            else {
                print("Download complete")

                // Download is complete, set the UIImageView to show the file that was downloaded
                let imgData = NSData(contentsOf: downloadFilePath!)
                let image = UIImage(data: imgData! as Data)
                //populate the filename : UIImage mapping for use in search
                self.fileMap[fileName] = image
                if(self.folderToObjectMap[folderName] != nil) {
                    self.folderToObjectMap[folderName]?.append((fileName,image!))
                } else {
                    self.folderToObjectMap[folderName] = [(fileName,image!)]
                }
            }
            completion(task)
            return nil
        }
    }
    
    public func getFilesInDirectory(folderName: String, completion: @escaping (AnyObject?)->()) {
        let files = folderMap[folderName]
        var cnt = files?.count
        if(cnt == folderToObjectMap[folderName]?.count) {
            completion(true as AnyObject)
            return
        }
        for file in files! {
            let path = userId+"/"+folderName+"/"+file
            getObject(path: path, folderName: folderName, fileName: file, completion: {result in
                if(result != nil) {
                    cnt = cnt! - 1
                    if(cnt == 0) {
                        completion(result)
                        return
                    }
                    
                } else {
                    print("Error in getting object")
                }
            })
        }
    }
    
    public func returnFilesInDirectory(folderName: String) -> [(String,UIImage)]{
        if let uw = folderToObjectMap[folderName] {
            return uw
        }
        else {
            return []
        }
    }
    

    
    public func putDirectory(folderName: String, completion: @escaping (AnyObject?)->()) {
        
        // Create a new put request to S3, and set its properties
        let putRequest = AWSS3PutObjectRequest()
        putRequest?.bucket = bucketName
        putRequest?.key = userId + "/" + folderName + "/"
        
        // Start asynchronous upload
        s3.putObject(putRequest!).continueWith { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error putting")
                print(task.error.debugDescription)
            }
            else {
                print("Put complete")
                // upload is complete, set the corresponding member vars
                if(folderName != self.sharedFolderName) {
                    self.allFiles.append(self.userId + "/" + folderName + "/")
                    self.folderMap[folderName] = []
                }
            }
            completion(task)
            return nil
        }
    }
    
    public func putFile(folderName: String, fileName: String, fileURL: URL, completion: @escaping (AnyObject?)->()) {
        print("put the file")
        let fileData = FileManager.default.contents(atPath: fileURL.path)
        let img = UIImage(data: fileData!)

        // Create a new put request to S3, and set its properties
        let putRequest = AWSS3PutObjectRequest()
        putRequest?.bucket = bucketName
        putRequest?.key = userId + "/" + folderName + "/" + fileName
        putRequest?.body = fileURL
        putRequest?.contentLength = NSData(data: fileData!).count as NSNumber;
        
        // Start asynchronous upload
        s3.putObject(putRequest!).continueWith { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error putting file")
                print(task.error.debugDescription)
            }
            else {
                print("Put file complete")
                // upload is complete, set the corresponding member vars
                self.allFiles.append(self.userId + "/" + folderName + "/" + fileName)
                self.folderMap[folderName]?.append(fileName)
                self.folderToObjectMap[folderName]?.append((fileName,img!))
            }
            completion(task)
            return nil
        }
    }
    
    public func shareFile(folderName: String, email: String, completion: @escaping (AnyObject?)->()) {
        
        let putRequest = AWSS3PutObjectRequest()
        putRequest?.bucket = bucketName
        putRequest?.key = email + "/" + sharedFolderName + "/" + userId + "/" + folderName

        // Start asynchronous upload
        s3.putObject(putRequest!).continueWith { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error sharing folder")
                print(task.error.debugDescription)
            }
            else {
                print("Put file complete")
                self.sendMail(emailAddr: email, subject: "AuRNote: Someone shared a notebook with you!", text: "Hi there!\n\nWe are emailing to notify you that " + self.userId + " shared the notebook: '" + folderName + "' with you. To view the notebook visit your Shared with me folder on the app.\n\nBest, \nTeam AuRNote" )

            }
            completion(task)
            return nil
        }
    }
    
    public func getSharedDirectories() -> Array<String> {
        return folderMap[self.sharedFolderName]!
    }
    
    public func getFilesInSharedDirectory(folderName: String, completion: @escaping (AnyObject?)->()) {
        
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "aurnotecs"
        listRequest.prefix = folderName + "/"

        //make the request and populate data
        var files = [String]()
        print("made request")
            s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
                for object in (task.result?.contents)! {
                    files.append(object.key!)
                }
                var cnt = 0
                if(files.count > cnt) {
                    cnt = files.count - 1
                }
                if(cnt == self.folderToObjectMap[folderName]?.count) {
                    completion(true as AnyObject)
                    return nil
                }
                for file in files {
                    if(file.suffix(1) == "/") {
                        continue
                    }
                    let atSlash = file.lastIndex(of: "/")
                    var fileName = file.suffix(from: atSlash!)
                    fileName.removeFirst()
                    self.getObject(path: file, folderName: folderName, fileName: String(fileName), completion: {result in
                       if(result != nil) {
                            cnt = cnt - 1
                           if(cnt == 0) {
                               completion(result)
                               return
                           }
                       } else {
                           print("Error in getting object")
                       }
                   })
                }
            return nil
        }
    }
    
    func sendMail(emailAddr: String, subject: String, text: String) {
        let sendGrid = SendGrid(withAPIKey: SENDGRID_API_KEY)
        
        let content = SGContent(type: .plain, value: text)
        let from = SGAddress(email: "noreply@aurnote.com")
        let personalization = SGPersonalization(to: [ SGAddress(email: emailAddr) ])
        
        let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
        
        sendGrid.send(email: email) { (response, error) in
            if let error = error {
                print("Error sending email: \(error.localizedDescription)")
            } else {
                print("Email sent!")
            }
        }
    }
          
}
