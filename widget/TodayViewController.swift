//
//  TodayViewController.swift
//  widget
//
//  Created by Jeong Jin Eun on 17/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import NotificationCenter

@objc(TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding {
    
    override func loadView() {
        view = TodayView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
