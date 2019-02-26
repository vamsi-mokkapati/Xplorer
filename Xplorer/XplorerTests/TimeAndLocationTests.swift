//

//
//  Created by Devan Dutta on 11/11/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import XCTest
import GoogleMaps
import GooglePlaces
@testable import Xplorer

class XplorerTests: XCTestCase {
    
    // Properties
    var timeAndLocationController:TimeAndLocationViewController!
    var autocompleteController:GMSAutocompleteViewController!
    var mapController:MapViewController!
    // Dummy place, a hotel in Saigon with an attribution.
    var placeID = "ChIJV4k8_9UodTERU5KXbkYpSYs"
    
    override func setUp() {
        super.setUp()
        // Put setup code here
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        timeAndLocationController = storyboard.instantiateViewController(withIdentifier: "timeAndLocation") as! TimeAndLocationViewController
        autocompleteController = GMSAutocompleteViewController()
        self.mapController = storyboard.instantiateViewController(withIdentifier: "mapView") as! MapViewController
        // run view did load
        _ = timeAndLocationController.view
        _ = mapController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTimeAndLocationControllerNotNull() {
        XCTAssertNotNil(timeAndLocationController)
    }
    
    func testAutoCompleteViewControllerNotNull(){
        XCTAssertNotNil(autocompleteController)
    }
    
    func testMapControllertNotNull(){
        XCTAssertNotNil(mapController)
    }
    
    func testTimeAndLocationViewIsNotNilAfterViewDidLoad(){
        XCTAssertNotNil(timeAndLocationController.view)
    }
    
    func testMapViewIsNotNilAfterViewDidLoad(){
        XCTAssertNotNil(mapController.view)
    }
    
    func testStartLocationNotNilAfterViewDidLoad(){
        XCTAssertNotNil(timeAndLocationController.startLocation)
    }
    
    func testStartPlaceGetsSelected(){
        mapController.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                XCTFail()
            }
            
            guard let place = place else {
                print("No place details for \(self.placeID)")
                XCTFail()
                return
            }
            self.timeAndLocationController.lastUITextFieldSelected = self.timeAndLocationController.startLocation
            self.timeAndLocationController.endPlace = nil
            self.timeAndLocationController.viewController(self.autocompleteController, didAutocompleteWith: place)
            XCTAssertNotNil(self.timeAndLocationController.startPlace)
            XCTAssertFalse(self.timeAndLocationController.doneButton.isEnabled)
            XCTAssertNil(self.timeAndLocationController.lastUITextFieldSelected)
            XCTAssertNil(self.timeAndLocationController.endPlace)
        })
    }
    
    func testEndPlaceGetsSelected(){
        mapController.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                XCTFail()
            }
            
            guard let place = place else {
                print("No place details for \(self.placeID)")
                XCTFail()
                return
            }
            self.timeAndLocationController.lastUITextFieldSelected = self.timeAndLocationController.endLocation
            self.timeAndLocationController.startPlace = nil
            self.timeAndLocationController.viewController(self.autocompleteController, didAutocompleteWith: place)
            XCTAssertNotNil(self.timeAndLocationController.endPlace)
            XCTAssertFalse(self.timeAndLocationController.doneButton.isEnabled)
            XCTAssertNil(self.timeAndLocationController.startPlace)
            XCTAssertNil(self.timeAndLocationController.lastUITextFieldSelected)
        })
    }
    
    func testDoneButtonEnablesAfterBothPlacesAreSelected(){
        mapController.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                XCTFail()
            }
            
            guard let place = place else {
                print("No place details for \(self.placeID)")
                XCTFail()
                return
            }
            self.timeAndLocationController.startPlace = place
            self.timeAndLocationController.endPlace = place
            self.timeAndLocationController.viewController(self.autocompleteController, didAutocompleteWith: place)
            XCTAssertTrue(self.timeAndLocationController.doneButton.isEnabled)
        })
    }
    
    func testTextFieldShouldReturn() {
        XCTAssertTrue(timeAndLocationController.textFieldShouldReturn(UITextField()))
    }
}
