//
//  AWSBucketHandler.swift
//  AurNote
//
//  Created by Sriharshini Duggirala on 2/20/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
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
    var folderToObjectMap = [String: [UIImage]]()
    let bucketName = "aurnotecs"
    
    
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
    
    ///gets the names of all files in the user's directory and stores it in a global variable
    /// - Parameter completion: this is an event callback that lets the caller execute some function after the request completes
    func getAllFiles(completion: @escaping (AnyObject?)->()) {
        
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "aurnotecs"
        listRequest.prefix = userId+"/"

        //make the request and populate data
        allFiles = []
        print("made request")
            s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
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
        for str in self.allFiles {
            var dir = (String(str.dropFirst(self.userId.count + 1)))
            let slashInd = dir.firstIndex(of: "/")
            if((slashInd) != nil) {
                let dirName = String(dir.prefix(upTo: slashInd!))
                if(folderMap[dirName] != nil) {
                    var temp = String(dir.suffix(from: slashInd!))
                    temp.removeFirst(1)
                    folderMap[dirName]?.append(temp)
                } else {
                    data.append(dirName)
                    folderMap[dirName] = []
                }
            }
        }
        print(folderMap)
        return data
    }
    
    func getObject(path: String, folderName: String, completion: @escaping (AnyObject?)->()) {
        
        // Hard-coded names for the tutorial bucket and the file uploaded at the beginning
        let dwnPath = path.replacingOccurrences(of: "/", with: "-")
        let downloadFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(dwnPath)
        
        
        // Set the logging to verbose so we can see in the debug console what is happening
        AWSLogger.default().logLevel = .verbose

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
                if(self.folderToObjectMap[folderName] != nil) {
                    self.folderToObjectMap[folderName]?.append(image!)
                } else {
                    self.folderToObjectMap[folderName] = [image!]
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
            getObject(path: path, folderName: folderName, completion: {result in
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
    
    public func returnFilesInDirectory(folderName: String) -> [UIImage]{
        return folderToObjectMap[folderName]!
    }
    
    public func returnfileLabelsInDirectory(folderName: String) -> [String] {
        return folderMap[folderName]!
    }
    
          
}
