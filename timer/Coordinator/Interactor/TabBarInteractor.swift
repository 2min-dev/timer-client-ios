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
    private let completeVelocity: CGFloat = 200.0
    private let cancleVelocity: CGFloat = 30.0
    private let direction: UIRectEdge
    
    // MARK: - properties
    private let gestureRecognizer: UIPanGestureRecognizer
    
    // MARK: - constructor
    init(gestureRecognizer: UIPanGestureRecognizer, direction: UIRectEdge) {
        self.gestureRecognizer = gestureRecognizer
        self.direction = direction
        super.init()
        
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(recognizer:)))
    }
    
    // MARK: - selector
    @objc private func handleGesture(recognizer: UIPanGestureRecognizer) {
        guard let containerView = gestureRecognizer.view else { return }
        
        let transition = gestureRecognizer.translation(in: containerView)
        let progress = transition.x / containerView.bounds.width
    
        switch recognizer.state {
        case .began:
            break
        case .changed:
            update(percentOfProgress(progress, by: direction))
        case .ended:
            let velocity = gestureRecognizer.velocity(in: containerView)
            
            var shouldComplete = false
            switch direction {
            case .left:
                shouldComplete = progress >= 0.5 || velocity.x > completeVelocity
            case .right:
                shouldComplete = progress <= -0.5 || velocity.x < completeVelocity
            default:
                break
            }
            
            if shouldComplete {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
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
