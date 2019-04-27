//
//  MainViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    // MARK: properties
    var coordinator: MainViewCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    deinit {
        Logger.verbose("")
    }
}
