//
//  StartViewController.swift
//  Xplorer
//
//  Created by Shashank Khanna on 12/7/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import Foundation
import UIKit

/**
 This class is used to present the Start view controller to the user upon first time opening the app.
 
 There is no logic within it.  Rather, it just serves as a container for the logo and a Start button, both of which are implemented in Storyboard
 
 */
class StartViewController : UIViewController {
    /**
     This method is called when the view controller is loaded.
     We have left default behavior because there is no customized loading happening.
     
     - Returns: void
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     This method is called when the view controller receives a memory warning.
     We have left default behavior.
     
     - Returns: void
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
