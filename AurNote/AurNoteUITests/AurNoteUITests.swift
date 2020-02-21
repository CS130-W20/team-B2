//
//  AurNoteUITests.swift
//  AurNoteUITests
//
//  Created by Kristi Richter on 2/21/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import XCTest

class AurNoteUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_login_UI() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let gidsigninbuttonButton = app/*@START_MENU_TOKEN@*/.buttons["GIDSignInButton"]/*[[".buttons[\"Sign in\"]",".buttons[\"GIDSignInButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        gidsigninbuttonButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        gidsigninbuttonButton.tap()
        app.alerts["“AurNote” Wants to Use “google.com” to Sign In"].scrollViews.otherElements.buttons["Cancel"].tap()
        

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test_folder_UI(){
        //sometimes fails bc the app varies its behavior - something to fix in next sprint
        let app = XCUIApplication()

        app.launch()
        
        let gidsigninbuttonButton = app/*@START_MENU_TOKEN@*/.buttons["GIDSignInButton"]/*[[".buttons[\"Sign in\"]",".buttons[\"GIDSignInButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        gidsigninbuttonButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        app.alerts["“AurNote” Wants to Use “google.com” to Sign In"].scrollViews.otherElements.buttons["Cancel"].tap()
        
        let noteviewButton = app.buttons["Note View"]
        noteviewButton.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["testFolder1"]/*[[".cells.staticTexts[\"testFolder1\"]",".staticTexts[\"testFolder1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
       
        let backButton = app.navigationBars["UICollectionView"].buttons["Back"]
        backButton.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["testFolder2"]/*[[".cells.staticTexts[\"testFolder2\"]",".staticTexts[\"testFolder2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        backButton.tap()
        
        collectionViewsQuery.staticTexts["testFolder3"].tap()
        backButton.tap()
        
        collectionViewsQuery.staticTexts["Add Folder"].tap()
        backButton.tap()
        
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Favorites"].tap()
        tabBarsQuery.buttons["More"].tap()
        
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
