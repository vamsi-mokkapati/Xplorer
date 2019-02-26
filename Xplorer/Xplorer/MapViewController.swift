//
//  ViewController.swift
//  Xplorer
//
//  Created by Devan Dutta on 11/11/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import os.log
import GoogleMaps
import GooglePlaces

/**
 The MapViewController is the main view controller for our app.  It prominently displays the map and is used to show the user's selected itinerary.
 
 MapViewController extends UIViewController.
 
 
 Properties:
 *  `currentLocation`:      a CLLocation that specifies the current location.
 *  `mapView`:              the main GMS mapview.  This is the view that is displayed full screen in this controller.
 *  `placesClient`:         a GMSPlacesClient variable so that we can make use of the Google Places API.
 *  `zoomLevel`:            indicates the zoom level of the map.
 *  `appDelegate`:          a reference back to the app's AppDelegate object.
 *  `markers`:              an array of GMSMarker objects that contain the markers on the map.
 *  `resultsReturned`:      The array of results returned by the nearby place lookup in dictionary form.
 *  `resultsData`:          The array of PlaceData objects for the returned POI results.
 *  `startLocation`:        CLLocationCoordinate2D that stores the user's start location.
 *  `endLocation`:          CLLocationCoordinate2D that stores the user's end location.
 *  `polylines`:            an array of GMSPolyline objects that represent the drawn routes on the map when the user selects POIs.
 *  `freeTime`:             an Int that represents how much more flexible time the user has to add POIs to his/her route.
 *  `defaultLocation`:      if the app is running in simulator mode, or if the user has not accepted location preferences, the map begins at Apple's headquarters.
 
 IBOutlets:
 *  `@IBOutlet tripPlanning`:           the right UIBarButtonItem on the navigation bar in the main map view that takes the user to the TimeAndLocationViewController.
 *  `@IBOutlet interestsBarButton`:     the left UIBarButtonItem on the navigation bar in the main map view that takes the user to the InterestViewController.
 *  `@IBOutlet POIList`:                the UITableView that is displayed containing possible POIs.
 *  `@IBOutlet directionsButton`:       the UIButton to take the user to Google Maps.
 *  `@IBOutlet flexibleTime`:           the UILabel that shows the user how much flexible time is remaining.
 
 Navigation:
 *  override func prepare (for segue: UIStoryboardSegue, sender: Any?): This method lets you prepare the view controller before it's presented.
 
 Actions:
 *  @IBAction func unwindToMapView(sender: UIStoryboardSegue): This method allows the TimeAndLocationViewController to unwind to this view controller.
 *  @IBAction func openGoogleMaps(_ sender: UIButton):         This method opens Google Maps once the user has finalized his/her POIs.
 
 Additional methods:
 *  override func viewDidLoad():                        This method specifies how to load the view.
 *  override func didReceiveMemoryWarning():            This method specifies what to do when memory warnings occur.
 *  func prepareFlexibleTime(seconds: Int):             This method updates the flexibleTime label.
 *  func returnPOITimeEstimate(types: [String]) -> Int: This method returns the time estimates for different POI types.
 *  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int:    This method returns the number of elements in a section of a UITableView.
 *  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell :   This method is used to populate the cells of the table.
 *  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath):  This method handles user selection of a cell in the table.
 *  addMarker(place: GMSPlace!, type: String):  This method adds a marker to the map.
 *  func updateMapZoom():                       This method updates the zoom of the map to contain all the markers.
 *  func updateMapPolyline():                   This method redraws the optimized route through the POIs.
 
 Delegates:
 *  CLLocationManagerDelegate:  The MapViewController has to implement the CLLocationManagerDelegate.
 */

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    //TODO: Move all properties above the UITableViewDelegate and UITableViewDataSource definitions

    //a CLLocation that specifies the current location.
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var markers: [GMSMarker] = []
    var resultsReturned: NSMutableArray = NSMutableArray()
    var resultsData: Array<PlaceData> = Array()
    var startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var polylines: [GMSPolyline] = []
    var freeTime: Int = 0
    var maxDurationForTravel : Int = 0
    
    @IBOutlet weak var backgroundProgressBar: UILabel!
    @IBOutlet weak var tripPlanning: UIBarButtonItem!
    @IBOutlet weak var interestsBarButton: UIBarButtonItem!
    @IBOutlet weak var POIList: UITableView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var flexibleTime: UILabel!
    @IBOutlet weak var progressBar: UIView!
    //In case the location preferences have not been set, this is the location of Apple headquarters
    let defaultLocation = CLLocation(latitude: 37.33182, longitude: -122.03118)

    /**
     This method is called when the view is loaded.
     We have overriden it to:
     *  Initialize the locationManager object.
     *  Initialize the placesClient object.
     *  Create a map to show:
     -   camera view
     -   map view
     -   center location button
     -   current location
     *  Add the map to the view
     
     - Returns: void
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialize the location manager
        appDelegate.locationManager = CLLocationManager()
        appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationManager.requestAlwaysAuthorization()
        appDelegate.locationManager.distanceFilter = 50
        appDelegate.locationManager.startUpdatingLocation()
        appDelegate.locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        //Create a Map to show
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
         // change the nav bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
        tripPlanning.setTitleTextAttributes([
                        NSAttributedStringKey.foregroundColor: UIColor.white,
                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
                        ], for: .normal)
        
        // Change the Interest bar button item (left bar button in map view)
        interestsBarButton.setTitleTextAttributes([
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
            ], for: .normal)
        
        // reset location to my location when the button is pressed
        mapView.settings.myLocationButton = true
        
        //Register the table view
//        POIList.register(POITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        POIList.dataSource = self
        POIList.delegate = self
        
        //Make the table view look nicer
        POIList.separatorColor = UIColor.blue
//        POIList.layer.cornerRadius = 10
        POIList.layer.masksToBounds = true
        
        //Add the map to the view
        view.addSubview(mapView)
        //Make the POI list hidden initially
        POIList.isHidden = true
        
        //Make the flexibleTime label hidden initially and set its parameters
        flexibleTime.numberOfLines = 2
        flexibleTime.isHidden = true
        flexibleTime.layer.cornerRadius = 8
       


        backgroundProgressBar.layer.borderColor = UIColor.white.cgColor
        backgroundProgressBar.layer.borderWidth = 1.0
        backgroundProgressBar.layer.cornerRadius = 8
        backgroundProgressBar.layer.borderColor = UIColor.white.cgColor
        backgroundProgressBar.layer.borderWidth = 1.0
        backgroundProgressBar.clipsToBounds = true
        backgroundProgressBar.isHidden = true
//        self.view.addSubview(backgroundProgressBar)
        
        
        //Hide the directions button
        directionsButton.isHidden = true
       
        
        self.view.addSubview(progressBar)
        progressBar.backgroundColor = UIColor.init(red:0.06, green:0.51, blue:0.88, alpha:1.0)
        progressBar.isHidden = true
        progressBar.layer.cornerRadius = 8
      
    }

    /**
     This method is called when the view controller receives a memory warning.
     
     - Returns: void
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     This method is used to update the time display in the flexible time remaining label.
     
     - Parameter seconds: An Int, all we need are the seconds to calculate the hours and minutes for the flexibleTime display
     
     - Returns: void
     
     */
    func prepareFlexibleTime(seconds: Int, maxDuration:Int) {
        let maxwidth = flexibleTime.frame.width
        let hours = seconds/3600
        let minutes = (seconds % 3600) / 60
        let timeText = "\(hours) hours, \(minutes) minutes"
        self.flexibleTime.text = timeText
        self.flexibleTime.isHidden = false
        self.progressBar.frame.size.width = maxwidth - (CGFloat(Float(seconds)/Float(maxDuration)) * maxwidth)
        print("max duration is \(maxDuration)")
        print("seconds are \(seconds)")
        print(self.progressBar.frame.size.width)
        progressBar.isHidden = false
        backgroundProgressBar.isHidden = false
        self.view.bringSubview(toFront: backgroundProgressBar)
        self.view.bringSubview(toFront: progressBar)
        self.view.bringSubview(toFront: flexibleTime)
    }
    
    /**
     This method is used to return how much time a user is expected to spend at a type of POI.
     
     We performed market research and read consumer reviews to figure out an average for how much time users would spend at:
     *  Night clubs
     *  Bars
     *  Amusement parks
     *  Aquariums
     *  Bowling alleys
     *  Movie theaters
     *  Zoos
     *  Parks
     *  Restaurants
     
     - Parameter types: An Array of Strings that designate the types for the current POI.
     
     - Returns: Int
     
     */
    func returnPOITimeEstimate(types: [String]) -> Int {
        var timeEstimate: Int = 0
        
        //It is possible for a bar to also be a night club, but if so, you would spend more time there
        if(types.contains("night_club") && types.contains("bar")) {
            //Probably will spend 4 hours at a night club: 60 seconds per minute * 60 minutes per hour * 4 hours
            timeEstimate = 60*60*4
        }
            
        else if (types.contains("amusement_park")) {
            //You would spend 8 hours in an amusement park: 60 seconds per minute * 60 minutes per hour * 8 hours
            timeEstimate = 60*60*8
        }
            
        else if(types.contains("aquarium")) {
            //You would spend 4 hours in an aquarium: 60 seconds per minute * 60 minutes per hour * 4 hours
            timeEstimate = 60*60*4
        }
            
        else if(types.contains("bowling_alley")) {
            //You would spend 2 hours in a bowling alley: 60 seconds per minute * 60 minutes per hour * 2 hours
            timeEstimate = 60*60*2
        }
            
        else if(types.contains("movie_theater")) {
            //Most movies will be 3 hours or less, so we go with 3 hours here: 60 seconds per minute * 60 minutes per hour * 3 hours
            timeEstimate = 60*60*3
        }
            
        else if(types.contains("zoo")) {
            //You would spend 4 hours in a zoo: 60 seconds per minute * 60 minutes per hour * 4 hours
            timeEstimate = 60*60*4
        }
            
        else if(types.contains("park")) {
            //You would spend an hour in a park: 60 seconds per minute * 60 minutes per hour * 1 hour
            timeEstimate = 60*60
        }
            
        else if(types.contains("bar") && types.contains("restaurant")) {
            //Probably will spend 2 hours in a bar with restaurant: 60 seconds per minute * 60 minutes per hour * 2 hours
            timeEstimate = 60*60*2
        }
            
        else if(types.contains("bar")) {
            //Probably will spend 2 hours in a bar: 60 seconds per minute * 60 minutes per hour * 2 hours
            timeEstimate = 60*60*2
        }
            
        else if(types.contains("restaurant")) {
            //Probably will spend 1 hour in a restaurant: 60 seconds per minute * 60 minutes per hour * 1 hour
            timeEstimate = 60*60
        }
        else {
            timeEstimate = 0
            print("No recognizable POI types")
        }
        
        return timeEstimate
    }
    
    /**
     This method is used to calculate the number of rows in a table.
     
     - Parameter tableView: A UITableView that contains the table.
     - Parameter section:   An Int specifying the number of rows in the section.
     
     - Returns: Int
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsReturned.count
    }
    
    /**
     This method is used to populate the cells of a table. We refer to our POI Array to populate the cells.
     
     - Parameter tableView: A UITableView that contains the table.
     - Parameter indexPath:   An IndexPath specifying the row index.
     
     - Returns: UITableViewCell
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath as IndexPath) as! POITableViewCell
        
        let result = resultsReturned[indexPath.row] as? NSDictionary
        cell.placeName.text = (result!["name"]) as? String
        cell.address.text = (result!["vicinity"]) as? String
        
        // Do price calculations
        let priceNumber = (result!["price_level"]) as? Int ?? 2
        var priceDict = [1:"$", 2:"$$", 3:"$$$", 4:"$$$$"]
        cell.price.text = priceDict[priceNumber]
        return cell
    }
    
    /**
     This method is used to handle user selection for a cell of the table.
     
     - Parameter tableView: A UITableView that contains the table.
     - Parameter indexPath: An IndexPath specifying the row index.
     
     - Returns: void
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = resultsData[indexPath.row]
        
        //Get type information
        let types = result.types
        
        //Check if the marker is already on the map, if so: remove it
        let position = result.coordinate.coordinate
        for marker:GMSMarker in markers {
            if ((position.latitude == marker.position.latitude) && (position.longitude == marker.position.longitude)) {
                print(marker)
                print("Number of items in markers before removal: \(markers.count)")
                
                let index = markers.index(where: { (item) -> Bool in
                    (item.position.latitude == position.latitude) && (item.position.longitude == position.longitude)
                })
                if(index! > 0) {
                    //Get the type information and update free time label
                    let timeToBeAdded = returnPOITimeEstimate(types: types)
                    self.freeTime = self.freeTime + timeToBeAdded
                    self.prepareFlexibleTime(seconds: freeTime, maxDuration: maxDurationForTravel)
                    
                    marker.map = nil
                    markers.remove(at: index!)
                    print("Number of items in markers after removal: \(markers.count)")
                    
                    for polyline in polylines {
                        polyline.map = nil
                    }
                    polylines.removeAll()
                    updateMapPolyline()
                    return
                }
            }
        }
        
        //Else, create marker to put on map if the user has enough time
        let subtractedTime = returnPOITimeEstimate(types: types)
        let timeLeft = freeTime - subtractedTime
        if(timeLeft > 0) {
            let marker = GMSMarker()
            marker.position = result.coordinate.coordinate
            marker.title = result.name
            marker.snippet = result.name
            marker.icon = GMSMarker.markerImage(with: UIColor.init(red: 0.192, green: 0.294, blue:0.4 , alpha: 1.0) ) // 0.192, 0.294, 0.4
            
            marker.appearAnimation = .pop
            marker.map = mapView
            markers.append(marker)
            
            for polyline in polylines {
                polyline.map = nil
            }
            polylines.removeAll()
            updateMapZoom()
            updateMapPolyline()
            
            //Update flexible time label
            freeTime = timeLeft
            self.prepareFlexibleTime(seconds: freeTime, maxDuration: maxDurationForTravel)
        }
            
        else {
            //Do not add the marker and polyline
            //Display alert instead
            
            let notEnoughTimeAlert = UIAlertController(title: "Not Enough Time!", message: "Your schedule looks pretty full! Time to get some directions!", preferredStyle: .alert)
            notEnoughTimeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {
                _ in NSLog("The \"OK\" alert occurred.")
            }))
            
            self.present(notEnoughTimeAlert, animated: true, completion: nil)
        }
        
    }
    
    
    //MARK: Navigation
    
    /**
     This method lets you prepare the view controller before it's presented.
     
     - Parameter segue: A UIStoryboardSegue that represents the segue.
     - Parameter sender: An Any object (any type) that is the sender of the event.
     
     - Returns: void
     
     */
    //This method lets you prepare the view controller before it's presented
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    //MARK: Actions
    
    /**
     This method opens Google Maps for directions once the user has selected their POIs.
     
     - Parameter sender: A UIButton object that is the sender of the event.
     
     - Returns: void
     
     */
    @IBAction func openGoogleMaps(_ sender: UIButton) {
        let originLat = String(describing: startLocation.latitude)
        let originLong = String(describing: startLocation.longitude)
        let endLat = String(describing: endLocation.latitude)
        let endLong = String(describing: endLocation.longitude)
        var url = "https://www.google.com/maps/dir/?api=1&"
        url += "origin=\(originLat),\(originLong)"
        url += "&destination=\(endLat),\(endLong)"
        
        //Add waypoints that are not the start nor end
        var waypointsString = ""
        for marker:GMSMarker in markers {
            var latBool: Bool
            latBool = ((marker.position.latitude != startLocation.latitude) && (marker.position.latitude != endLocation.latitude))
            var lonBool: Bool
            lonBool = ((marker.position.longitude != startLocation.longitude) && (marker.position.longitude != endLocation.longitude))
            
            //The marker is different from the start and end
            if ((latBool == true) && (lonBool == true)) {
                let waypointLatString = String(describing: marker.position.latitude)
                let waypointLonString = String(describing: marker.position.longitude)
                waypointsString += "\(waypointLatString),\(waypointLonString)|"
            }
            
        }
        //Remove last pipe:
        if (waypointsString.last == "|") {
            waypointsString.remove(at: waypointsString.index(before: waypointsString.endIndex))
        }
        //url += "dir_action=navigate"
        url += "&waypoints="
        url += waypointsString
        
        //print(url)
        
        let formattedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //print(formattedURL)
        let urlQuery = URL(string: formattedURL!)!
        UIApplication.shared.open(urlQuery, options: [:], completionHandler: nil)
    }
    
    
    /**
     This method is used for the "Done" button in the TimeAndLocationViewController.
     
     Because we want to get back to this view, we need to unwind from the TimeAndLocationViewController.
     To prepare to unwind, we:
     *  Get the start and end places as GMSPlace objects
     *  Get the start and end times from the `UIDatePicker` objects in the TimeAndLocationViewController.
     *  Add markers to the map, specifying the start and end locations that the user selected.
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     - Parameter sender: The sender is the object that prepares for and performs the visual transition between two view controllers.  It supports all visual transitions that have been defined in UIKit.
     
     - Returns: void
     
     */
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TimeAndLocationViewController {
            
            //Check first if the cancel button was pressed on the TimeAndLocationViewController:
            //If so, then just return and do nothing:
            let userCanceled = sourceViewController.cancelPressed
            if (userCanceled == true) {
                return
            }
            
            // Before getting the start and end place, remove any previous markers that were on the map
            for marker in markers {
                marker.map = nil
            }
            markers.removeAll()
            
            // Also, remove any polylines that were on the map:
            for polyline in polylines {
                polyline.map = nil
            }
            polylines.removeAll()
            
            // Also, remove all resultsReturned and resultsData from any previous user info
            self.resultsData.removeAll()
            self.resultsReturned.removeAllObjects()
            
            // Get the start place and the end place
            let startPlace = sourceViewController.startPlace
            let endPlace = sourceViewController.endPlace
            
            // Get the start time and the end time
            let startTime = sourceViewController.startTimeInfo
            let endTime = sourceViewController.endTimeInfo
            
            print("startPlace: \(startPlace!.name), \(startPlace!.formattedAddress!)")
            print("endPlace: \(endPlace!.name), \(endPlace!.formattedAddress!)")
            
            print("startTime: \(startTime!)")
            print("endTime: \(endTime!)")
            
            // Set up initial time for flexibleTime
            let seconds = Int(sourceViewController.userTimeIntervalDouble - sourceViewController.totalDuration)
            freeTime = seconds
            maxDurationForTravel = seconds
            self.prepareFlexibleTime(seconds: seconds, maxDuration: maxDurationForTravel)
            
            //Put start and end markers on map
            addMarker(place: startPlace, type: "start")
            addMarker(place: endPlace, type: "end")
            
            startLocation = (startPlace?.coordinate)!
            endLocation = (endPlace?.coordinate)!
            
            //Draw optimized route between start and end
            updateMapPolyline()
            
            //Move the "myLocationButton" and Google attribution up so that the POI list doesn't block it
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
            
            /* TODO: Fix map zooming and camera position when receiving new start and end itinerary from user
            //Make the map's camera position be the new start, as opposed to current location
            //  Note that the zoom position is temporary right now, because it will be updated with updateMapZoom()
            let newPosition = GMSCameraPosition.camera(withLatitude: startLocation.latitude, longitude: endLocation.longitude, zoom: 8)
            mapView.camera = newPosition
 */
            
            //Modify the map bounds to include all markers
            updateMapZoom()
            
            
            //Get midpoint
            let longitude1: Double = Double(startPlace!.coordinate.longitude) * .pi / 180
            let longitude2: Double = Double(endPlace!.coordinate.longitude) * .pi / 180
            let latitude1: Double = Double(startPlace!.coordinate.latitude) * .pi / 180
            let latitude2: Double = Double(endPlace!.coordinate.latitude) * .pi / 180
            
            let longitudeDistance = longitude2 - longitude1
            
            let x = cos(latitude2) * cos(longitudeDistance)
            let y = cos(latitude2) * sin(longitudeDistance)
            
            let latitude3 = atan2(sin(latitude1) + sin(latitude2), sqrt((cos(latitude1) + x) * (cos(latitude1) + x) + y * y))
            let longitude3 = longitude1 + atan2(y, cos(latitude1) + x)
            
            var center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude3 * 180 / .pi, longitude: longitude3 * 180 / .pi)
            
            
            // If you would like to see where the center is, then uncomment this code:
            /*
            let marker = GMSMarker()
            marker.position = center
            
            marker.appearAnimation = .pop
            marker.map = mapView
            markers.append(marker)
            
            updateMapZoom()
             */
            
            //Now get the POIs:
            let centerLat = String(describing: center.latitude)
            let centerLong = String(describing: center.longitude)

            //Get distance between end points
            let start: CLLocation = CLLocation(latitude: (startPlace?.coordinate.latitude)!, longitude: (startPlace?.coordinate.longitude)!)
            let end: CLLocation = CLLocation(latitude: (endPlace?.coordinate.latitude)!, longitude: (endPlace?.coordinate.longitude)!)
            let endToEndDistanceMeters = end.distance(from: start)
            //Get radius
            let radius = endToEndDistanceMeters / 2
            print("radius: \(radius)")
            let radiusString = String(describing: radius)
            
            /*
                The following process will have to be repeated for all the user's selected POI types:
 
                1. Query for POIs of that type
                2. Add the top 5 POIs of the queried type to the POIList
             
            */
            
            let interests = UserDefaults.standard.array(forKey: "interests")! as Array
            //Remove duplicates:
            var uniqueInterests = Set<String>()
            for interest in interests {
                let interest = interest as! String
                uniqueInterests.insert(interest)
            }
            
            //Use this approach to query for multiple POI types
            for interest in uniqueInterests {
                print("Querying for: \(interest)")
                
                var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(centerLat),\(centerLong)&radius=\(radiusString)&type=\(interest)&key=\(appDelegate.GMSPlacesWebServicesKey)"
                
                let url = URL(string: urlString)
                let request = URLRequest(url: url!)
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    let task = session.dataTask(with: request) {data, response, error in
                        do {
                            let json = (try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary)!
                            let results = json["results"] as? NSArray
                            
                            for place:Any in results! {
                                self.resultsReturned.add(place)
                            }
                            group.leave()
                            return
                        } catch {
                            print(error)
                            group.leave()
                            return
                        }
                    }
                    task.resume()
                }
                
                group.notify(queue: .main) {
                    print("Here are the returned results:")
                    //resultsReturned is an array of dictionaries
                    for result:Any in self.resultsReturned {
                        if let dictionaryResult = result as? NSDictionary {
                            let placeID = dictionaryResult["id"]
                            let name = dictionaryResult["name"]
                            let types = dictionaryResult["types"] as! Array<String>
                            let geometry = dictionaryResult["geometry"] as? NSDictionary
                            let location = geometry!["location"] as? NSDictionary
                            let latitude = location!["lat"]
                            let longitude = location!["lng"]
                            let placeInfo = PlaceData(name: name as! String, id: placeID as! String, coordinate: CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees), types: types)
                            
                            if self.resultsData.contains(where: {$0.id == (placeID as! String)}) {
                                //Do nothing
                            }
                            else {
                                self.resultsData.append(placeInfo)
                            }
                            
                            print("name: \(String(describing: name))")
                            print(dictionaryResult)
                            
                        }
                    }
                    
                    self.POIList.reloadData()
                    self.POIList.isHidden = false
                    self.view.bringSubview(toFront: self.POIList)
                    
                    self.directionsButton.isHidden = false
                    self.view.bringSubview(toFront: self.directionsButton)
                }
                
            }
            
            /*
            var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(centerLat),\(centerLong)&radius=\(radiusString)&type=restaurant&key=\(appDelegate.GMSPlacesWebServicesKey)"
            
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                let task = session.dataTask(with: request) {data, response, error in
                    do {
                        let json = (try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary)!
                        let results = json["results"] as? NSArray
                        
                        for place:Any in results! {
                            self.resultsReturned.add(place)
                        }
                        group.leave()
                        return
                    } catch {
                        print(error)
                        group.leave()
                        return
                    }
                }
                task.resume()
            }
            
            group.notify(queue: .main) {
                print("Here are the returned results:")
                //resultsReturned is an array of dictionaries
                for result:Any in self.resultsReturned {
                    if let dictionaryResult = result as? NSDictionary {
                        let placeID = dictionaryResult["id"]
                        let name = dictionaryResult["name"]
                        let types = dictionaryResult["types"] as! Array<String>
                        let geometry = dictionaryResult["geometry"] as? NSDictionary
                        let location = geometry!["location"] as? NSDictionary
                        let latitude = location!["lat"]
                        let longitude = location!["lng"]
                        let placeInfo = PlaceData(name: name as! String, id: placeID as! String, coordinate: CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees), types: types)
                        
                        self.resultsData.append(placeInfo)
                        
                        print("name: \(String(describing: name))")
                        
                    }
                }
                
                self.POIList.reloadData()
                self.POIList.isHidden = false
                self.view.bringSubview(toFront: self.POIList)
                
                self.directionsButton.isHidden = false
                self.view.bringSubview(toFront: self.directionsButton)
            }
 */
        }
    }
    
    /**
     This function adds a marker to the map.
     
     - Parameter place: The GMSPlace that represents the place you want to add to the map.
     - Parameter type:  Specifies whether the marker will be for a "start" or an "end" location.
     - Returns: void
     */
    func addMarker(place: GMSPlace!, type: String) {
        let marker = GMSMarker()
        marker.position = (place?.coordinate)!
        marker.title = place?.name
        marker.snippet = place?.formattedAddress
        if(type == "start") {
            marker.icon = GMSMarker.markerImage(with: UIColor.init(red: 0.027, green: 0.561, blue: 0.365, alpha: 1.0))
            
        }
        
        else if(type == "end") {
            marker.icon = GMSMarker.markerImage(with: UIColor.init(red: 0.643, green: 0.078, blue: 0.157, alpha: 1.0))
        }
        marker.appearAnimation = .pop
        marker.map = mapView
        markers.append(marker)
    }
    
    /**
     This function updates the zoom of the map to contain all the markers.
     
     - Returns: void
     */
    func updateMapZoom() {
        let path = GMSMutablePath()
        for marker:GMSMarker in markers {
            path.add(marker.position)
        }
        
        let bounds = GMSCoordinateBounds.init(path: path)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 150)
        
        mapView.animate(with: update)
    }
    
    /**
     This function redraws the optimized route through the POIs..
     
     - Returns: void
     */
    func updateMapPolyline() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Construct the request:
        let originLat = String(describing: startLocation.latitude)
        let originLong = String(describing: startLocation.longitude)
        let endLat = String(describing: endLocation.latitude)
        let endLong = String(describing: endLocation.longitude)
        var url = "https://maps.googleapis.com/maps/api/directions/json?"
        url += "origin=\(originLat),\(originLong)"
        url += "&destination=\(endLat),\(endLong)"
        
        //Add waypoints that are not the start nor end
        var waypointsString = ""
        for marker:GMSMarker in markers {
            var latBool: Bool
            latBool = ((marker.position.latitude != startLocation.latitude) && (marker.position.latitude != endLocation.latitude))
            var lonBool: Bool
            lonBool = ((marker.position.longitude != startLocation.longitude) && (marker.position.longitude != endLocation.longitude))
            
            //The marker is different from the start and end
            if ((latBool == true) && (lonBool == true)) {
                let waypointLatString = String(describing: marker.position.latitude)
                let waypointLonString = String(describing: marker.position.longitude)
                waypointsString += "\(waypointLatString),\(waypointLonString)|"
            }
                
        }
        //Remove last pipe:
        if (waypointsString.last == "|") {
            waypointsString.remove(at: waypointsString.index(before: waypointsString.endIndex))
        }
        url += "&waypoints=optimize:true|"
        url += waypointsString
        url += "&key=\(appDelegate.GMSDirectionsKey)"
        
        //print(url)
        
        let formattedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //print(formattedURL)
        let urlQuery = URL(string: formattedURL!)!
        
        //Query Google Directions API to get polyline back:
        var polylinePoints = ""
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            let task = session.dataTask(with: urlQuery) {data, response, error in
                do {
                    if error != nil {
                        print("error: \(error?.localizedDescription)")
                        return
                    }
                    
                    //print("Is valid JSON: \(data)")

                    
                    let json = (try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary)!
                    let routes = json["routes"] as! NSArray
                    let route1 = routes[0] as! NSDictionary
                    let overviewPolyline = route1["overview_polyline"] as? NSDictionary
                    polylinePoints = overviewPolyline!["points"] as! String
                    
                    //Update time estimates
                    let legs = route1["legs"] as! NSArray
                    
                    for leg in legs {
                        let legDict = leg as! NSDictionary
                        let steps = legDict["steps"] as! NSArray
                        for step in steps {
                            let step = step as! NSDictionary
                            let duration = step["duration"] as! NSDictionary
                            let value = duration["value"] as! Int
                            
                            //TODO: Add to some total travel time here
                            //self.totalTravelTime += Double(value)
                        }
                    }
                    
                    group.leave()
                    return
                } catch {
                    print(error)
                    group.leave()
                    return
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            print("Drawing polyline now:")
            let path = GMSMutablePath(fromEncodedPath: polylinePoints)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3
            polyline.strokeColor = UIColor.init(red:0.06, green:0.51, blue:0.88, alpha:1.0)
                //UIColor.init(red: 0.58, green: 0.624, blue:0.71 , alpha: 1.0) // 0.58, 0.624, 0.71

            polyline.map = self.mapView
            
            for polyline in self.polylines {
                polyline.map = nil
            }
            self.polylines.removeAll()
            self.polylines.append(polyline)
            
            let bounds = GMSCoordinateBounds.init(path: path!)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 110)
            self.mapView.animate(with: update)
            
            
        }
    }
}

//MARK: Delegates

/**
 The MapViewController must implement the CLLocationManagerDelegate protocol, which specifies the methods used to receive events from locationManager.
 
 */
extension MapViewController: CLLocationManagerDelegate {
    
    /*
     Tells the delegate that new location data is available.
     
     - Parameter manager:   The location manager object that generated the update event.
     - Parameter locations: An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
     
     - Discussion: Implementation of this method is optional but recommended.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        appDelegate.locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

/**
 The PlaceData struct is an object encapsulation of relevant information regarding place objects.
 
 
 Properties:
 *  `name`:             a String representing the name of the place.
 *  `id`:               a String representing the Google Places id of the place.
 *  `coordinate`:       a CLLocation that represents the coordinates of the place.
 *  `types`:            an Array of Strings that hold the POI types for the place.

 */
struct PlaceData {
    var name: String
    var id: String
    var coordinate: CLLocation
    var types: [String]
}

