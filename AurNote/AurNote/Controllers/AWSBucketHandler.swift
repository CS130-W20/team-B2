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
    
    
    ///initializes and configures credential provider with userpool id and credentials
    /// - Parameter id: a unique identifier for the logged in user, also the name of their folder in the S3 bucket
    init(id: String) {
        self.userId = id
        
        // initializing credential provider
        let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: myIdentityPoolId)
        configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

    }
    
    ///gets the names of all files in the user's directory and stores it in a global variable
    /// - Parameter completion: this is an event callback that lets the caller execute some function after the request completes
    func getAllFiles(completion: @escaping (AnyObject?)->()) {
        
        //register the config
        AWSS3.register(with: configuration, forKey: "defaultKey")
        let s3 = AWSS3.s3(forKey: "defaultKey")
        
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
          
}
