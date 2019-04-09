//
//  UIView+autolayout.swift
//  TaskManager-Swift
//
//  Created by Jeong Jin Eun on 25/02/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setSubviewForAutoLayout(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
    }
    
    func setSubviewsForAutoLayout(_ subviews: [UIView]) {
        subviews.forEach(setSubviewForAutoLayout)
    }
}
