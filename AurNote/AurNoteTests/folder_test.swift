//
//  folder_test.swift
//  AurNoteTests
//
//  Created by Kristi Richter on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import XCTest
@testable import AurNote

class folder_test: XCTestCase {

    override func setUp() {
        //super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        //super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_folder() {
        
        let awsBucketHandler = AWSBucketHandler(id: "testUser")
        let awsBucketHandler_bad = AWSBucketHandler(id: "BAD_USER")

        //username = testUser
        //PASS: 3 folders received
        //FAIL : folders received != 3
        
        awsBucketHandler.getAllFiles(completion: { result in
            if(result == nil) {
                assert(false)
            } else {
                let dirs = awsBucketHandler.getDirectories()
                XCTAssert(dirs.count == 3, "Wrong number of directories returned for testUser")
            }
            
        })


        //username = random
            //PASS: 0 folders found
            //FAIL: any folders found
        
        awsBucketHandler_bad.getAllFiles(completion: { result in
            if(result == nil) {
                XCTAssert(true, "Bad user should not have any files")
            } else {
                let dirs = awsBucketHandler_bad.getDirectories()
                XCTAssert(dirs.count == 0, "Wrong number of directories returned for BAD_USER")
            }
            
        })
 

    }

    func folder_perf() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
