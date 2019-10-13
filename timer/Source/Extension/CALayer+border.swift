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
    
    func shadowWithAnimation(color: UIColor = .black, alpha: Float = 0.5, offset: CGSize, blur: CGFloat = 0, spread: CGFloat = 0, duration: CFTimeInterval = 0.2) {
        let shadowColorAnimation = CABasicAnimation(keyPath: "shadowColor")
        shadowColorAnimation.toValue = color.cgColor
        
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.toValue = alpha
        
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shadowOffsetAnimation.toValue = offset
        
        let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        shadowRadiusAnimation.toValue = blur / 2.0
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.toValue = UIBezierPath(rect: bounds.insetBy(dx: -spread, dy: -spread)).cgPath
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [shadowColorAnimation,
                                     shadowOpacityAnimation,
                                     shadowOffsetAnimation,
                                     shadowRadiusAnimation,
                                     shadowPathAnimation]
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.duration = duration
        
        CATransaction.setCompletionBlock {
            self.shadow(color: color, alpha: alpha, offset: offset, blur: blur, spread: spread)
        }
        
        CATransaction.begin()
        add(animationGroup, forKey: "shadow")
        CATransaction.commit()
    }
}
