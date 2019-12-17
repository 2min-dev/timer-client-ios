//
//  IntroCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from intro view
class IntroViewCoordinator: NSObject, ViewCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case main
        case timeSetProcess
    }
    
    // MARK: - properties
    unowned var viewController: UIViewController!
    var dismiss: ((UIViewController) -> Void)?
    
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    @discardableResult
    func present(for route: Route) -> UIViewController? {
        guard case (let controller, var coordinator)? = get(for: route) else { return nil }
        let presentingViewController = controller

        // Set transition delegate
        viewController.navigationController?.delegate = self
        
        switch route {
        case .main:
            // Present main view
            viewController.navigationController?.setViewControllers([presentingViewController], animated: true)
            
        case .timeSetProcess:
            guard let mainViewController = get(for: .main)?.controller else { return nil }
            
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.setViewControllers([mainViewController, presentingViewController], animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .main:
            let dependency = MainViewBuilder.Dependency(provider: provider)
            return MainViewBuilder(with: dependency).build()
            
        case .timeSetProcess:
            let dependency = TimeSetProcessViewBuilder.Dependency(provider: provider)
            return TimeSetProcessViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
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
