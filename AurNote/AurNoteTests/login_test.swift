//
//  AurNoteTests.swift
//  AurNoteTests
//
//  Created by Kristi Richter on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import XCTest
@testable import AurNote

class login_test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_login() {
        // valid login credentials
            //PASS: Authenticated
            //FAIL: not authenticated and given access
        
        //invalid login credentials
            //PASS: ask to re-enter
            //FAIL: gives access
    }

    func login_perf() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
