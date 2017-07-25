//
//  InterfaceController.swift
//  watchOS Extension
//
//  Created by Meniny on 2017-07-25.
//  Copyright © 2017年 Meniny. All rights reserved.
//

import WatchKit
import Foundation
import Imagery

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
