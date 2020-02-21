//
//  overlay_test.swift
//  AurNoteTests
//
//  Created by Kristi Richter on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import XCTest

class overlay_test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func box_detection_test() {
        //One rectangle on paper (should detect box)
            //PASS: detects one rectangle
            //FAIL: detects 0 or multiple rectangles
        
        //No box rectangle drawn
            //PASS: no rectangle detected
            //FAIL: detects rectangle
        
        //Multiple boxes (Should only show top result)
            //PASS: shows top result
            //FAIL: shows something other than top result

        }
    
    func overlay_test(){
        //Box in various parts of pages
            //PASS: overlays the image on any part of the paper
            //FAIL: overlays image in center of paper regardless of where the box is
        
        //Overlays in different levels of closeness to the paper
            //PASS: overlays the box as long as the entire box is within the camera and easily visible to the camera
            //FAIL: overlays image on wrong part of the paper, doesn’t fully overlay on the box

    }

    func overlay_perf() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
