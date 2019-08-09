//
//  CALayer+border.swift
//  timer
//
//  Created by JSilver on 19/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension CALayer {
    func border(edges: [UIRectEdge], width: CGFloat, color: UIColor) {
        // Remove all sub layer
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Create border layer
        edges.forEach { edge in
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect(x: 0, y: 0, width: bounds.width, height: width)
            case UIRectEdge.bottom:
                border.frame = CGRect(x: 0, y: bounds.height - width, width: bounds.width, height: width)
            case UIRectEdge.left:
                border.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
            case UIRectEdge.right:
                border.frame = CGRect(x: bounds.width - width, y: 0, width: width, height: bounds.height)
            default:
                break
            }
            
            border.backgroundColor = color.cgColor
            addSublayer(border) // Add border layer
        }
    }
    
    func shadow(color: UIColor = .black, alpha: Float = 0.5, offset: CGSize, blur: CGFloat = 0, spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = offset
        shadowRadius = blur / 2.0
        if spread == 0 {
          shadowPath = nil
        } else {
          let dx = -spread
          let rect = bounds.insetBy(dx: dx, dy: dx)
          shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
