//
//  AppDelegate.swift
//  Xplorer
//
//  Created by Devan Dutta on 11/11/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
/**
 The AppDelegate is responsible for all main operation of the app.  It is a Singleton instance that maintains state for the whole app.
 
 It extends UIResponder and implements UIApplicationDelegate.
 
 Note about properties:
 *  `window` is a UIWindow that specifies the window space of the application
 *  `locationManager` is necessary to start and stop the delivery of location-related events to the app
 *  `GMSMapServicesKey` is the Google Maps iOS API key for our project
 *  `GMSPlacesServicesKey` is the Google Places iOS API key for our project
 *  `GMSPlacesServicesKey_alternate` is an alternate Google Places iOS API key for our project (we were running up API quotas)
 *  `GMSPlacesWebServicesKey` is the Google Places Web API key for our project
 *  `GMSDirectionsKey` is the Google Directions Web API key for our project
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Properties
    
    var window: UIWindow?
    // location manager is a singleton and is shared via app delegate
    var locationManager = CLLocationManager()
    var GMSMapServicesKey = "AIzaSyByB7OVg04q9jIAawE1i4IN0Il8I3Na1pU"
    var GMSPlacesServicesKey = "AIzaSyByB7OVg04q9jIAawE1i4IN0Il8I3Na1pU"
    var GMSPlacesServicesKey_Alternate = "AIzaSyBbr2HM01bQwUpnJQGKlihQBy1GQ76ocpU"
    var GMSPlacesWebServicesKey = "AIzaSyBYGcQrEimBrhEY6wYzLMHqisvxg0GkRf8"
    var GMSDirectionsKey = "AIzaSyB1uYtfQ892wpwjxF4Nmoepb-YUjs79G3w"
    
    //MARK: Methods
    
    /**
     This method is used for when the application starts up.
     
     We provide the GMSMapServices and GMSPlacesClient API keys here.
     
     We also control whether the interest view controller is loaded first after the splashscreen (user has just installed app)
     
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     - Parameter launchOptions: Any specified launch options.
     - Returns: true
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GMSMapServicesKey)
        GMSPlacesClient.provideAPIKey(GMSPlacesServicesKey_Alternate)
       
        // The first time a user opens the app, the user must see an onboarding screen
        // asking about the user's interests
        // After that, they should be re-directed to the home screen
        
        self.window = UIWindow(frame:UIScreen.main.bounds)
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        var vc : UIViewController
        if (UserDefaults.standard.value(forKey: "interests") as? [String]) == nil {
            // show the onboarding screen
            vc = storyboard.instantiateViewController(withIdentifier: "StartViewController")
        } else {
            //print(UserDefaults.standard.value(forKey: "interests")!)
            vc = storyboard.instantiateInitialViewController()!
        }
        
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        return true
    }
    
    /**
     This method is sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     
     This method can be used to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
     
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     
     - Returns: void
     */
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    /**
     This method is used to release shared resources, save user data, invalidate timers, and store enough application state information to restore the application to its current state in case it is terminated later.
     
     If the app supports background execution, this method is called instead of `applicationWillTerminate()` when the user quits.
     
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     
      - Returns: void
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    /**
     This method is called as part of the transition from the background to the active state; here we can undo many of the changes made on entering the background.
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     
      - Returns: void
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    /**
     This method is used to restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     
      - Returns: void
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    /**
     Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     
     - Parameter application: The centralized point of control and coordination for iOS apps.  There is one instance of a UIApplication for every app.
     
      - Returns: void
     */
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

