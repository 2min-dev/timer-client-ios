//
//  IntroCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from intro view
class IntroViewCoordinator: NSObject, CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case main
    }
    
    // MARK: - properties
    weak var viewController: IntroViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .main:
            // Present main view
            self.viewController.navigationController?.delegate = self
            self.viewController.navigationController?.setViewControllers([viewController], animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .main:
            let coordinator = MainViewCoordinator(provider: provider)
            let viewController = MainViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            
            // set tab bar view controller initial index
            viewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
            return viewController
        }
    }
}

extension IntroViewCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        default:
            return IntroAnimator()
        }
    }
}

class IntroAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    // Duration of transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // Get from, to view controller of transition
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return UIViewPropertyAnimator() }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return UIViewPropertyAnimator() }

        // Add view
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        // Set init frame
        toVC.view.frame = fromVC.view.frame

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeOut) {
            fromVC.view.alpha = 0
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        return animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
}
