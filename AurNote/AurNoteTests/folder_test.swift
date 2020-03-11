//
//  folder_test.swift
//  AurNoteTests
//
//  Created by Kristi Richter on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import XCTest
import AWSCognito
import AWSCore
import AWSS3
import AurNote

class folder_test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func folder_test() {
        //username = testUser
            //PASS: 3 folders received
            //FAIL : folders received != 3
        
        //username = random
            //PASS: 0 folders found
            //FAIL: any folders found

    }

    func folder_perf() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
