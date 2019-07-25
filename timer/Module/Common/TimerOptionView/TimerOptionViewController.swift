//
//  TimerOptionViewController.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimerOptionViewController: UINavigationController {
    // MARK: - properties
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide top navigtaion bar
        isNavigationBarHidden = true
        // Set root view controller
        viewControllers = [TimerOptionMainViewController()]
    }
    
    deinit {
        Logger.verbose()
    }
}
