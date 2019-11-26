//
//  UIView+autolayout.swift
//  timer
//
//  Created by Jeong Jin Eun on 25/02/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var _safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func addAutolayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
    }
    
    func addAutolayoutSubviews(_ subviews: [UIView]) {
        subviews.forEach(addAutolayoutSubview)
    }
}
