//
//  POITableViewCell.swift
//  Xplorer
//
//  Created by Shashank Khanna on 12/11/17.
//  Copyright © 2017 devan.dutta. All rights reserved.
//

import Foundation
import UIKit

/**
 The POITableCell defines how each cell in the POI table is constructed.
 
 POITableCell extends UIViewController.
 
 
 Properties:
 *  `placeName`:            a UILabel that displays the place information.
 *  `address`:              a UILabel that displays the address of the POI.
 *  `price`:                a UILabel that displays a relative price in some number of dollar signs from 1 to 4, inclusive
 */
class POITableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeName: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var price: UILabel!
}
