//
//  TimeAndLocationViewController.swift
//  Xplorer
//
//  Created by Devan Dutta on 11/11/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


/**
 This class is used as the Time and Location Input Controller for the user.
 It is in this view that the user is able to select a start location, start time, end location, and end time.
 
 This class extends UIViewController and implements UITextFieldDelegate and GMSAutocompleteViewControllerDelegate.
 
 Properties:
 *  `lastUITextFieldSelected`:      A UITextField that represents the last text field that the user selected and indicates to the view whether to place the user's searched location in the start or end text field.
 *  `startPlace`:                   A GMSPlace that represents the start place.
 *  `endPlace`:                     A GMSPlace that represents the end place.
 *  `startTimeInfo`:                An NSDate that represents the start time.
 *  `endTimeInfo`:                  An NSDate that represents the end time.
 *  `userTimeIntervalDouble`:       A Double representing the user entered time delta in seconds.
 *  `totalDuration`:                A Double representing how long it will take to get from the startPlace to the endPlace.
 *  `cancelPressed`:                A Bool that records whether the user cancelled the input selection.
 
 Outlets:
 *  startLocation:  UITextField that holds the start location.
 *  endLocation:    UITextField that holds the end location.
 *  startTime:      UIDatePicker that holds the start time.
 *  endTime:        UIDatePicker that holds the end time.
 *  doneButton:     UIBarButtonItem that sits to the right in the navigation bar and only activates once the user has selected valid start and end locations.
 *  cancelButton:   UIBarButtonItem that sits to the left in the navigation bar and returns back to the map view.
 
 Constants:
 *  appDelegate:    This is a reference to the application's AppDelegate object.
 
 */
class TimeAndLocationViewController: UIViewController, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    //MARK: Properties
    var lastUITextFieldSelected: UITextField?
    var startPlace: GMSPlace?
    var endPlace: GMSPlace?
    var startTimeInfo: NSDate?
    var endTimeInfo: NSDate?
    var userTimeIntervalDouble: Double = 0
    var totalDuration: Double = 0
    var cancelPressed: Bool = false
    
    // Outlets
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var endLocation: UITextField!
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // Constants and variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // --------------------
    //MARK: SETUP
    // --------------------
    
    /**
     This method is called when the view is loaded.
     We have overriden it to:
     *  Initially disable the "Done" button.
     *  Set this class as the delegate for the start and end UITextField objects.
     
     - Returns: void
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false
        startLocation.delegate = self
        endLocation.delegate = self
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        startLocation.leftView = paddingView
        startLocation.leftViewMode = .always
        let paddingView2: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        endLocation.leftView = paddingView2
        endLocation.leftViewMode = .always
        
        // change the nav bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        self.cancelPressed = false
        
    }

    /**
     This method is used to dispose of any resources that can be recreated in the event of a memory warning.
     - Returns: void
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // --------------------
    //MARK: AUTOCOMPLETE
    // --------------------
    
    /**
     This function is invoked whenever the GMSAutocompleteView loads after tapping on either startLocation or endLocation.
     
     - Parameter viewController:    This object refers to the GMS-specific view controller that called this method.
     - Parameter place:             This object refers to the user's selection in the autofill suggestions.
     
     - Returns: void
     
     If both the startPlace and the endPlace are valid, then the "Done" button is activated.
     
     The view controller dismisses itself after a valid user selection.
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        lastUITextFieldSelected?.text = "\(place.name), \(place.formattedAddress!)"
        if (lastUITextFieldSelected === startLocation) {
            startPlace = place
        }
        else {
            endPlace = place
        }
        lastUITextFieldSelected = nil
        
        
        if((startPlace != nil) && (endPlace != nil)) {
            doneButton.isEnabled = true
        }
        
        self.dismiss(animated: true, completion: nil) // dismiss after selecting a place
    }
    
    /**
     
     This method handles GSM-specific view controller issues.
     
     This method is one of the GMSAutocompleteViewControllerDelegate methods.
     
     - Parameter viewController:    This object refers to the GMS-specific view controller that called this method.
     - Parameter error:             Specifies the error that was received from the GMSAutocompleteViewController.
     
     - Returns: void
     */
    // fail with error
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error){
        print("Error AutoComplete \(error) )")
    }
    
    /**
     This method is called when the user cancels entering text.
     This method is one of the GMSAutocompleteViewControllerDelegate methods.
     
     - Parameter viewController:    This object refers to the GMS-specific view controller that called this method.
     
     - Returns: void
     */
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
    This method deals with presenting the AutoCompleteViewController whenever either of the location UITextFields is selected.
     
     - Parameter sender:    This object represents the specific UITextField that was tapped on.
     
     - Returns: void
    */
    func handleAutocomplete(sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        appDelegate.locationManager.startUpdatingLocation()
        lastUITextFieldSelected = sender
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    /**
     This method is the action handler (and is specified with @IBAction) for the startLocation UITextField.
     
     - Parameter sender:    This object represents the specific UITextField that was tapped on.
     
     - Returns: void
     */
    @IBAction func openSearchAddressStartPlace(_ sender: UITextField) {
        handleAutocomplete(sender: sender)
    }
    
    /**
     This method is the action handler (and is specified with @IBAction) for the cancelButton UIBarButtonItem.
     
     It simply:
     *  Records that the user canceled inputting parameters
     *  Unwinds to the map view
     
     - Parameter sender:    This object represents the specific UIBarButtonItem that was tapped on.
     
     - Returns: void
     */
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.cancelPressed = true
        self.performSegue(withIdentifier: "unwindToMapViewIdentifier", sender: self)
    }
    
    
    /**
     This method is the action handler (and is specified with @IBAction) for the endLocation UITextField.
     
     - Parameter sender: This object represents the specific UITextField that was tapped on.
     
     - Returns: void
     */
    @IBAction func openSearchAddressEndPlace(_ sender: UITextField) {
        handleAutocomplete(sender: sender)
    }
    
    /**
     This method is the action handler (and is specified with @IBAction) for the doneButton UIBarButtonItem.
     
     It simply:
     *  Validates the user input for times and for locations
     *  Unwinds to the map view
     
     - Parameter sender:    This object represents the specific UIBarButtonItem that was tapped on.
     
     - Returns: void
     */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        //COMPARE LOCATIONS:
        let placeID1 = startPlace?.placeID
        let placeID2 = endPlace?.placeID
        
        if (placeID1 == placeID2) {
            let placeAlert = UIAlertController(title: "Place Error", message: "The start and end locations must be different.", preferredStyle: .alert)
            placeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {
                _ in NSLog("The \"OK\" alert occurred.")
            }))
            
            self.present(placeAlert, animated: true, completion: nil)
            return
        }
        
        //COMPARE TIMES:
        startTimeInfo = startTime.date as NSDate?
        endTimeInfo = endTime.date as NSDate?
        
        print("end time: \(endTime.date)")
        print("start time: \(startTime.date)")
        
        var order = NSCalendar.current.compare(startTimeInfo! as Date, to: endTimeInfo as! Date, toGranularity: .minute)
        
        if ((order == .orderedSame) || (order == .orderedDescending)) {
            let timeAlert = UIAlertController(title: "Time Error", message: "The end time must be later than the start time.", preferredStyle: .alert)
            timeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {
                _ in NSLog("The \"OK\" alert occurred.")
            }))
            
            self.present(timeAlert, animated: true, completion: nil)
            return
        }
        
        //SEE IF START AND END TIMES ARE REALISTIC:
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Construct the request:
        let originLat = String(describing: startPlace!.coordinate.latitude)
        let originLong = String(describing: startPlace!.coordinate.longitude)
        let endLat = String(describing: endPlace!.coordinate.latitude)
        let endLong = String(describing: endPlace!.coordinate.longitude)
        var url = "https://maps.googleapis.com/maps/api/directions/json?"
        url += "origin=\(originLat),\(originLong)"
        url += "&destination=\(endLat),\(endLong)"
        url += "&key=\(appDelegate.GMSDirectionsKey)"
        
        print(url)
        
        let formattedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //print(formattedURL)
        let urlQuery = URL(string: formattedURL!)!
        
        //Query Google Directions API to get time back:
        //totalDuration is the total duration in seconds of the journey
        self.totalDuration = 0
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
                    let legs = route1["legs"] as! NSArray
                    
                    for leg in legs {
                        let legDict = leg as! NSDictionary
                        let steps = legDict["steps"] as! NSArray
                        for step in steps {
                            let step = step as! NSDictionary
                            let duration = step["duration"] as! NSDictionary
                            let value = duration["value"] as! Int
                            self.totalDuration += Double(value)
                        }
                    }
                    
                    group.leave()

                } catch {
                    print(error)
                    group.leave()
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            print("Total length (in seconds): \(self.totalDuration)")
            
            // See if there is enough time to get to the destination by driving:
            self.startTimeInfo = self.startTime.date as NSDate
            self.endTimeInfo = self.endTime.date as NSDate
            let userTimeInterval = self.endTimeInfo?.timeIntervalSince(self.startTimeInfo as! Date)
            print ("user time interval: \(userTimeInterval)")
            self.userTimeIntervalDouble = userTimeInterval as! Double
            
            if (self.userTimeIntervalDouble < self.totalDuration) {
                //Calculate how much more time is necessary
                let timeDelta = self.totalDuration - self.userTimeIntervalDouble
                var minuteDelta = Int(timeDelta / 60) + 1
                
                let insufficientTimeAlert = UIAlertController(title: "Insufficient Time", message: "No way you can get there that fast! Please provide at least \(minuteDelta) more minutes.", preferredStyle: .alert)
                insufficientTimeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {
                    _ in NSLog("The \"OK\" alert occurred.")
                }))
                
                self.present(insufficientTimeAlert, animated: true, completion: nil)
            }
            
            else {
                //If all the other checks are alright, then perform the segue
                self.performSegue(withIdentifier: "unwindToMapViewIdentifier", sender: self)
            }
        }
 
    }
    
    
    // --------------------
    //MARK: UITextFieldDelegate
    // --------------------
    
    /**
     This method is one of the methods that should be implemented for UITextFieldDelegate.
     
     It specifies what to do when the user presses "Enter".
     
     - Parameter textField: The UITextField whose return button was pressed.
     
     - Returns: true
     
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    /**
     This method tells the delegate that editing stopped for the specified text field.
     
     - Parameter textField: The UITextField for which editing ended.
     
     - Returns: void
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /**
     This method is used to prepare for a segue.  It notifies the view controller that a segue is about to be performed.
     
     The method checks to see if the sender was a UIBarButtonItem (in this case "Done") and then sets the startTimeInfo and endTimeInfo objects to be relayed to the MapViewController upon the unwindToMapView() method in MapViewController.
     
     - Parameter segue:     The UIStoryboardSegue object that contains information about the view controllers involved in the segue.
     
     - Parameter sender:    The object that initiated the segue.  Based on what the sender is, the behavior of this function can be decided at runtime.
     
     - Returns: void
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Note that the 3 equal signs do not indicate a typo.  They are the identity operator.
        //Specifically, they are checking if the object referenced by sender is the same as doneButton
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            print("The done button was not pressed")
            return
        }
        
        startTimeInfo = startTime.date as NSDate
        endTimeInfo = endTime.date as NSDate
    }
}
