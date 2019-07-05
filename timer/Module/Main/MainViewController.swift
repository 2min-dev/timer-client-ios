//
//  MainViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    // MARK: - constants
    enum TabType: Int {
        case LocalTimeSet = 0
        case Productivity
        case SharedTimeSet
    }
    
    // MARK: - properties
    var coordinator: MainViewCoordinator!
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var panGestureDirection: UIRectEdge?
    
    // Enable/Disable swipes on the tab bar controller
    var swipeEnable = true {
        didSet { panGestureRecognizer.isEnabled = swipeEnable }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Color.white
        
        // Set tab bar view controller delegate for swipable
        delegate = self
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler(recognizer:)))
        panGestureRecognizer.delegate = self
        
        view.addGestureRecognizer(panGestureRecognizer)
        
        tabBar.tintColor = Constants.Color.black
    }
    
    // MARK: - selector
    @objc private func gestureHandler(recognizer: UIPanGestureRecognizer) {
        // Do not attempt to begin an interactive transition if one is already
        guard transitionCoordinator == nil else {
            return
        }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            
            if translation.x > 0.0 && selectedIndex > 0 {
                // Panning right, transition to the left view controller.
                panGestureDirection = .left
                selectedIndex -= 1
            } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
                // Panning left, transition to the right view controller.
                panGestureDirection = .right
                selectedIndex += 1
            }
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - extension
extension MainViewController: UITabBarControllerDelegate {
    // Return animator of transitioning when tab changed
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarAnimator(tabBarController: self)
    }
    
    // Return interactor of transitioning animator when tab changed
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // Return interactor only change selected tab by pan gesture
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            return TabBarInteractor(gestureRecognizer: panGestureRecognizer, direction: panGestureDirection ?? .top)
        } else {
            return nil
        }
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    // Return gesture recognizer interpert touch event only tab view controller is single
    // * non single view like navigation controller or etc *
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let currentViewController = selectedViewController as? UINavigationController else { return true }
        return currentViewController.viewControllers.count > 1 ? false : true
    }
}
