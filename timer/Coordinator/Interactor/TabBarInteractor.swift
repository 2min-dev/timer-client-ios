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
    
    // MARK: - properties
    private let gestureRecognizer: UIPanGestureRecognizer
    
    // MARK: - constructor
    init(gestureRecognizer: UIPanGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
        super.init()
        
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(recognizer:)))
    }
    
    // MARK: - selector
    @objc private func handleGesture(recognizer: UIPanGestureRecognizer) {
        guard let containerView = gestureRecognizer.view else { return }
        
        let transition = gestureRecognizer.translation(in: containerView)
        let progress = min(max(abs(transition.x) / containerView.bounds.width, 0.01), 0.99)
    
        switch recognizer.state {
        case .began:
            break
        case .changed:
            update(progress)
        case .ended:
            let velocity = gestureRecognizer.velocity(in: containerView)
            
            if progress >= 0.5 || abs(velocity.x) > completeVelocity {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
}
