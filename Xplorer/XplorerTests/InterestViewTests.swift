//
//  InterestViewTests.swift
//  XplorerTests
//
//  Created by Avirudh Theraja on 12/12/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import XCTest
import GoogleMaps
import GooglePlaces
@testable import Xplorer

class InterestsTest : XCTestCase {
    // Properties
    var interestController:InterestViewController!
    var dummySender:UIButton!
    
    override func setUp() {
        super.setUp()
        // Put setup code here
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        interestController = storyboard.instantiateViewController(withIdentifier: "interest") as! InterestViewController
        dummySender = UIButton.init()
        // run view did load
        _ = interestController.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInterestControllerNotNull() {
        XCTAssertNotNil(interestController)
    }
    
    func testInterestControllerViewNotNilAfterLoad() {
        XCTAssertNotNil(interestController.view)
    }
    
    func testInterestsEmptyInitially() {
        XCTAssertTrue(interestController.interests.isEmpty)
    }
    
    func testSelectEntertainment() {
        interestController.select_Entertainment(dummySender)
        XCTAssertTrue(interestController.interests.elementsEqual(["amusement_park", "aquarium", "bowling_alley", "movie_theater", "zoo"]))
    }
    
    func testSelectGardens() {
        interestController.selectGardens(dummySender)
        XCTAssertTrue(interestController.interests.elementsEqual(["park"]))
    }
    
    func testSelectFood() {
        interestController.selectFood(dummySender)
        XCTAssertTrue(interestController.interests.elementsEqual(["restaurant"]))
    }
    
    func testSelectDrinks() {
        interestController.selectDrinks(dummySender)
        XCTAssertTrue(interestController.interests.elementsEqual(["bar", "night_club"]))
    }
    
    func testSelectAll() {
        interestController.select_Entertainment(dummySender)
        interestController.selectGardens(dummySender)
        interestController.selectFood(dummySender)
        interestController.selectDrinks(dummySender)
        XCTAssertTrue(interestController.interests.elementsEqual(["amusement_park", "aquarium", "bowling_alley", "movie_theater", "zoo", "park", "restaurant", "bar", "night_club"]))
    }
}
