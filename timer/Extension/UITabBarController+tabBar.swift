//
//  ViewController.swift
//  timer
//
//  Created by JSilver on 07/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension UITabBarController {
    func setTabBarHidden(_ isHidden: Bool, animate: Bool) {
        let keyWindow = UIApplication.shared.keyWindow!
        
        // Calc tab bar frame
        var origin = tabBar.frame.origin
        origin = CGPoint(x: 0, y: isHidden ? keyWindow.frame.height : keyWindow.frame.height - tabBar.frame.height)
        
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.tabBar.frame.origin = origin
            }
        } else {
            tabBar.frame.origin = origin
        }
    }
}
