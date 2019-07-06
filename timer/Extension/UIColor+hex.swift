//
//  UIColor.swift
//  timer
//
//  Created by Jeong Jin Eun on 29/12/2018.
//  Copyright © 2018 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        var colorStr: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if colorStr.hasPrefix("#") && colorStr.count == 7 {
            colorStr.remove(at: colorStr.startIndex)
            if let rgb: Int = Int(colorStr, radix: 16) {
                self.init(
                    red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                    green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                    blue: CGFloat(rgb & 0x0000FF) / 255.0,
                    alpha: CGFloat(1.0)
                )
            } else {
                self.init(red: 0, green: 0, blue: 0, alpha: 1)
            }
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
