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
        
        let gidsigninbuttonButton = app.buttons["GIDSignInButton"]
        gidsigninbuttonButton.tap()
        /*
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        gidsigninbuttonButton.tap()
        app.alerts["“AurNote” Wants to Use “google.com” to Sign In"].scrollViews.otherElements.buttons["Cancel"].tap()
        */

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test_folder_UI(){
        //sometimes fails bc the app varies its behavior - something to fix in next sprint
        let app = XCUIApplication()

        app.launch()
        
        let gidsigninbuttonButton = app.buttons["GIDSignInButton"]
        gidsigninbuttonButton.tap()
        /*
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
 */
        
    }
    
    func testSharedFolder(){
        
        let app = XCUIApplication()
        app.navigationBars["Shared with me"].buttons["My Notes"].tap()
        app.navigationBars["cs133"].buttons["My Notes"].tap()
        app.buttons["profile (unselected)"].tap()
        app.buttons["Logout Button"].tap()
    }
    
    func testAddFolder(){
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"Add Folder").element.tap()
        app.alerts["Create folder"].scrollViews.otherElements.buttons["Ok"].tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Math"]/*[[".cells.staticTexts[\"Math\"]",".staticTexts[\"Math\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Math 33b"].buttons["My Notes"].tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
    }
    
    func testLogout(){
        let app = XCUIApplication()
        app.buttons["profile (unselected)"].tap()
        app.buttons["Logout Button"].tap()
    }
    
    func testImageAndCropping(){
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["33b"]/*[[".cells.staticTexts[\"33b\"]",".staticTexts[\"33b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let math33bNavigationBar = app.navigationBars["Math 33b"]
        math33bNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        app.buttons["camera shutter"].tap()
        
        let element3 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        let element2 = element3.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element = element2.children(matching: .other).element(boundBy: 2)
        element.tap()
        element2.children(matching: .other).element(boundBy: 4).tap()
        element.swipeLeft()
        element2.children(matching: .other).element(boundBy: 3).swipeLeft()
        app.navigationBars["編輯"].buttons["下一步"].tap()
        app.navigationBars["回顧"].buttons["Done"].tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 2).otherElements.containing(.image, identifier:"Image Background (criss-cross)").element.tap()
        element3.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        math33bNavigationBar.buttons["My Notes"].tap()
    }
    
    func testImageInsertion(){
        let app = XCUIApplication()
        let math33bNavigationBar = app.navigationBars["Math 33b"]
        let collectionViewsQuery = app.collectionViews
        let myNotesButton = math33bNavigationBar.buttons["My Notes"]
        myNotesButton.tap()
        let staticText = collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["33b"]/*[[".cells.staticTexts[\"33b\"]",".staticTexts[\"33b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let itemButton = math33bNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 1)
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        
        let element2 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Math"]/*[[".cells.staticTexts[\"Math\"]",".staticTexts[\"Math\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.cells.otherElements.containing(.image, identifier:"Image Background (criss-cross)").element.tap()
        element2.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        let element3 = element2.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element4 = element3.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        //let element = element4.children(matching: .other).element(boundBy: 0)
        myNotesButton.tap()
        let cameraShutterButton = app.buttons["camera shutter"]
        app.buttons["Camera"].tap()
        app.buttons["Add New Picture"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["PhotoCapture"]/*[[".buttons[\"Take Picture\"]",".buttons[\"PhotoCapture\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Use Photo"].tap()
        element3.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        staticText.tap()
        myNotesButton.tap()
        staticText.tap()
        itemButton.tap()
        cameraShutterButton.tap()
        element4.children(matching: .other).element(boundBy: 4).swipeRight()
        element4.children(matching: .other).element(boundBy: 2)/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.tap()
    }
    func testSearch(){
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.tap()
        
        let imageBackgroundCrissCrossElement = collectionViewsQuery.cells.otherElements.containing(.image, identifier:"Image Background (criss-cross)").element
        imageBackgroundCrissCrossElement.tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        app.navigationBars["cs133"].buttons["My Notes"].tap()
        
        let myNotesNavigationBar = app.navigationBars["My Notes"]
        let searchSearchField = myNotesNavigationBar.searchFields["Search"]
        searchSearchField.tap()
        
        let hKey = app/*@START_MENU_TOKEN@*/.keys["H"]/*[[".keyboards.keys[\"H\"]",".keys[\"H\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        hKey.tap()
        hKey.tap()
        
        let lKey = app/*@START_MENU_TOKEN@*/.keys["l"]/*[[".keyboards.keys[\"l\"]",".keys[\"l\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        lKey.tap()
        lKey.tap()
        
        let oKey = app/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        oKey.tap()
        oKey.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        imageBackgroundCrissCrossElement.tap()
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        searchSearchField.tap()
        myNotesNavigationBar.buttons["Cancel"].tap()

    }
    
    func testCroppingAndImageStorage(){
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        let staticText = collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["33b"]/*[[".cells.staticTexts[\"33b\"]",".staticTexts[\"33b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText.tap()
        
        let math33bNavigationBar = app.navigationBars["Math 33b"]
        let itemButton = math33bNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 1)
        itemButton.tap()
        
        let cameraShutterButton = app.buttons["camera shutter"]
        cameraShutterButton.tap()
        
        let element2 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        let element3 = element2.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element4 = element3.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element = element4.children(matching: .other).element(boundBy: 0)
        element.tap()
        app.navigationBars["編輯"].buttons["下一步"].tap()
        app.navigationBars["回顧"].buttons["Done"].tap()
        app/*@START_MENU_TOKEN@*/.collectionViews.containing(.other, identifier:"Vertical scroll bar, 1 page").element/*[[".collectionViews.containing(.other, identifier:\"Horizontal scroll bar, 1 page\").element",".collectionViews.containing(.other, identifier:\"Vertical scroll bar, 1 page\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
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
