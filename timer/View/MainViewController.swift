//
//  MainViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    // MARK: - properties
    var coordinator: MainViewCoordinator!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Set tab bar view controller delegate for swipable
        delegate = self
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    deinit {
        Logger.verbose("")
    }
    
    // MARK: -selector
    @objc private func gestureHandler(recognizer: UIPanGestureRecognizer) {
        // Do not attempt to begin an interactive transition if one is already
        guard transitionCoordinator == nil else {
            return
        }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            
            if translation.x > 0.0 && selectedIndex > 0 {
                // Panning right, transition to the left view controller.
                selectedIndex -= 1
            } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
                // Panning left, transition to the right view controller.
                selectedIndex += 1
            }
        }
    }
}

extension MainViewController: UITabBarControllerDelegate {
    // Return animator of transitioning when tab changed
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarAnimator(tabBarController: self)
    }
    
    // Return interactor of transitioning animator when tab changed
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return TabBarInteractor(gestureRecognizer: panGestureRecognizer)
    }
}
