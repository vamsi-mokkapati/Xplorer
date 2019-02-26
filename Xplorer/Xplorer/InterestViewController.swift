//
//  InterestViewController.swift
//  Xplorer
//
//  Created by Shashank Khanna on 12/7/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import Foundation
import UIKit

/**
 The InterestViewController is where the user selects his/her interests.
 
 InterestViewController extends UIViewController.
 
 Note that we have time estimates for each kind of POI based on market research and consumer reviews.  The time estimates are in the MapViewController and are used to indicate to the user how much more flexible time he/she has.
 
 
 Properties:
 *  `interests`:            an Array of Strings that represent the interests.
 
 Actions:
 *  @IBAction func select_Entertainment(_ sender: UIButton): This action allows a user to toggle the Entertainment POI type
 *  @IBAction func selectGardens(_ sender: UIButton): This action allows a user to toggle the Gardens POI type
 *  @IBAction func selectDrinks(_ sender: UIButton): This action allows a user to toggle the Drinks POI type
 *  @IBAction func selectFood(_ sender: UIButton): This action allows a user to toggle the Food POI type
 *  @IBAction func continuePressed(_ sender: UIButton): This action allows the user to confirm their POI interests and go into the main map view
 
 Additional methods:
 override func viewDidLoad(): This method is for loading the view.
 
 override func didReceiveMemoryWarning(): This method is for telling the app what to do when a memory warning appears.
 
 */
class InterestViewController: UIViewController {
    var interests : [String] = []
    var user_selected_interests : [String]  = []
    
    @IBOutlet weak var drinks_btn: UIButton!
    @IBOutlet weak var gardens_btn: UIButton!
    @IBOutlet weak var entertainment_btn: UIButton!
    @IBOutlet weak var food_btn: UIButton!
    /**
     This method is used for loading the view.
     - Returns: void
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        var pressed_buttons = UserDefaults.standard.array(forKey: "user_selected_interests")
        
        if ((pressed_buttons) != nil) {
            for button in pressed_buttons!{
                if(button as! String == "entertainment"){
                    select_Entertainment(entertainment_btn)
                } else if (button as! String == "gardens"){
                    selectGardens(gardens_btn)
                } else if (button as! String == "drinks") {
                    selectGardens(drinks_btn)
                } else if (button as! String == "food") {
                    selectFood(food_btn)
                }
             }
        }
    }
    
    /**
     This method tells the view controller how to respond when there is a memory warning
     - Returns: void
     
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     This method represents the action for toggling the Entertainment POI.
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     When the user selects Entertainment, what we query for are: amusement parks, aquariums, bowling alleys, movie theaters, and zoos.
     
     - Parameter sender: The sender is the UIButton object that represents what the user tapped on
     
     - Returns: void
     
     */
    @IBAction func select_Entertainment(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        /*
         Append only the POI types that can be directly queried in Google Places Web API
         "Entertainment" is incredibly vague, so we will consider:
         "amusement_park", "aquarium", "bowling_alley", "movie_theater", "zoo"
         */
        
        interests.append("amusement_park")
        interests.append("aquarium")
        interests.append("bowling_alley")
        interests.append("movie_theater")
        interests.append("zoo")
        user_selected_interests.append("entertainment")
    }
    
    /**
     This method represents the action for toggling the Gardens POI.
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     When the user selects Gardens, what we query for are: parks
     
     - Parameter sender: The sender is the UIButton object that represents what the user tapped on
     
     - Returns: void
     
     */
    @IBAction func selectGardens(_ sender: UIButton) {
         sender.isSelected = !sender.isSelected
        interests.append("park")
        user_selected_interests.append("gardens")
    }
    
    /**
     This method represents the action for toggling the Drinks POI.
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     When the user selects Drinks, what we query for are: bars, night clubs
     
     - Parameter sender: The sender is the UIButton object that represents what the user tapped on
     
     - Returns: void
     
     */
    @IBAction func selectDrinks(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        interests.append("bar")
        interests.append("night_club")
        user_selected_interests.append("drinks")
    }
    
    /**
     This method represents the action for toggling the Food POI.
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     When the user selects Food, what we query for are: restaurants
     
     - Parameter sender: The sender is the UIButton object that represents what the user tapped on
     
     - Returns: void
     
     */
    @IBAction func selectFood(_ sender: UIButton) {
         sender.isSelected = !sender.isSelected
        interests.append("restaurant")
        user_selected_interests.append("food")
    }
    
    /**
     This method represents the action for saving the user's interests and continuing to the map view
     
     The method is specified with an @IBAction tag to denote that it is an action that an UI element can be linked to.
     
     - Parameter sender: The sender is the UIButton object that represents what the user tapped on
     
     - Returns: void
     
     */
    @IBAction func continuePressed(_ sender: UIButton) {
        UserDefaults.standard.set(interests, forKey: "interests")
        UserDefaults.standard.set(user_selected_interests, forKey: "user_selected_interests")
        //print(UserDefaults.standard.value(forKey: "interests")!)
        performSegue(withIdentifier: "toMainSegue", sender: self)
    }
}
