//
//  UITabBar.swift
//  timer
//
//  Created by JSilver on 23/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension UITabBar {
    // Set tab bar height
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            return super.sizeThatFits(size)
        }
        
        var sizeThatFits = super.sizeThatFits(size)
        if #available(iOS 11.0, *) {
            // calc additional pt about safearea
            sizeThatFits.height = window.safeAreaInsets.bottom + 61.adjust()
        } else {
            sizeThatFits.height = 61.adjust()
        }
        return sizeThatFits
    }
}
