//
//  IntegrationTest.swift
//  XplorerTests
//
//  Created by Avirudh Theraja on 12/14/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import XCTest
import GoogleMaps
import GooglePlaces
@testable import Xplorer

class IntegrationTest : XCTestCase {
    var timeAndLocationController:TimeAndLocationViewController!
    // PlaceID of TLT in Westwood
    var startPlaceId = "ChIJtSJ9j4G8woARVGVwDskvFJA"
    // PlaceID of Philz Coffee Santa Monica
    var endPlaceId = "ChIJG3ywZ86kwoARDUqrEUbuulw"
    var timeIntervalGap:TimeInterval = 7200
    var mapController:MapViewController!
    var autocompleteController:GMSAutocompleteViewController!
    var group:DispatchGroup!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        group = DispatchGroup()
        timeAndLocationController = storyboard.instantiateViewController(withIdentifier: "timeAndLocation") as! TimeAndLocationViewController
        autocompleteController = GMSAutocompleteViewController()
        self.mapController = storyboard.instantiateViewController(withIdentifier: "mapView") as! MapViewController
        // run view did load
        _ = timeAndLocationController.view
        _ = mapController.view
    }
    
    func setStartAndEndPlace() {
        group.enter()
        self.mapController.placesClient.lookUpPlaceID(self.startPlaceId, callback: { (startPlace, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                XCTFail()
            }
            guard let startPlace = startPlace else {
                print("No place details for \(self.startPlaceId)")
                XCTFail()
                return
            }
            self.timeAndLocationController.startPlace = startPlace
            self.group.leave()
        })
        group.enter()
        self.mapController.placesClient.lookUpPlaceID(self.endPlaceId, callback: { (endPlace, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                XCTFail()
            }
            
            guard let endPlace = endPlace else {
                print("No place details for \(self.startPlaceId)")
                XCTFail()
                return
            }
            self.timeAndLocationController.endPlace = endPlace
            self.group.leave()
        })
        group.notify(queue: .main) {
            // Now we have start and end places set
            return
        }
    }
    
    func setStartAndEndTime() {
        timeAndLocationController.startTimeInfo = NSDate.init()
        timeAndLocationController.endTimeInfo = NSDate.init(timeIntervalSinceNow: timeIntervalGap)
    }
    
    /**
     Detailed integration test which tests the entire flow of the app. We first set the start and end places by using hardcoded values
     for places in Los Angeles. We then specify a time interval of 2 hours, with our start time being the current time during execution. We then simulate the pressing of the done button. Upon success, we transition to the map view by calling unwindToMapView. This function parses the user input and draws the route on the map, thus completing the functionality.
    **/
    func testIntegrationTest() {
        setStartAndEndPlace()
        setStartAndEndTime()
        timeAndLocationController.doneButtonPressed(UIBarButtonItem.init())
        // If no errors, transition to MapViewController by calling unwindToMapViewIdentifier
        timeAndLocationController.performSegue(withIdentifier: "unwindToMapViewIdentifier", sender: timeAndLocationController)
        // If we reach here, then our mapView controller was able to depict the route to the user
        // Update polyline, should not throw any errors
        mapController.updateMapPolyline()
    }
}
