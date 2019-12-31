//
//  TabBarInteractor.swift
//  timer
//
//  Created by JSilver on 15/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TabBarInteractor: UIPercentDrivenInteractiveTransition {
    // MARK: - constants
    private let completeVelocity: CGFloat = 200
    private let cancleVelocity: CGFloat = 30
    
    // MARK: - properties
    private let tabBarAnimator: UIViewPropertyAnimator
    private let gesture: UIPanGestureRecognizer
    private let direction: UIRectEdge
    
    // MARK: - constructor
    init?(tabBarAnimator: UIViewPropertyAnimator, gesture: UIPanGestureRecognizer, direction: UIRectEdge) {
        guard direction == .left || direction == .right else { return nil }
        
        self.tabBarAnimator = tabBarAnimator
        self.gesture = gesture
        self.direction = direction
        super.init()
        
        gesture.addTarget(self, action: #selector(panGestureHandler))
    }
    
    // MARK: - selector
    @objc private func panGestureHandler(gesture: UIPanGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        
        let transition = gesture.translation(in: containerView)
        let progress = transition.x / containerView.bounds.width
    
        switch gesture.state {
        case .began:
            break
            
        case .changed:
            let percent = percentOfProgress(progress, by: direction)
            
            update(percent)
            tabBarAnimator.fractionComplete = percent // Update tab bar animator
            
        case .ended:
            let velocity = gesture.velocity(in: containerView)
            
            var shouldComplete = false
            switch direction {
            case .left:
                shouldComplete = progress >= 0.5 || velocity.x > completeVelocity
                
            case .right:
                shouldComplete = progress <= -0.5 || velocity.x < -completeVelocity
                
            default:
                break
            }
            
            if shouldComplete {
                finish()
            } else {
                cancel()
                tabBarAnimator.isReversed = true // Tab bar animator reverse when transition canceled
            }
            tabBarAnimator.startAnimation() // Resume tab bar animation
            
            // Remove gesture recognizer when pan gesture ended (1 transition - 1 swipe)
            gesture.removeTarget(self, action: #selector(panGestureHandler))
            
        default:
            cancel()
            
            tabBarAnimator.isReversed = true
            tabBarAnimator.startAnimation()

            gesture.removeTarget(self, action: #selector(panGestureHandler))
        }
    }
    
    /// Get percent of progress by gesture direction
    private func percentOfProgress(_ progress: CGFloat, by direction: UIRectEdge) -> CGFloat {
        switch direction {
        case .left:
            return abs(min(max(progress, 0), 1))
            
        case .right:
            return abs(max(min(progress, 0), -1))
            
        default:
            return 0
        }
    }
}
