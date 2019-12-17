//
//  TimeSetProcessViewCoordinator.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetProcessViewCoordinator: ViewCoordinator, ServiceContainer {
    // MARK: - route enumeration
    enum Route {
        case dismiss(animated: Bool)
        case home
        case timeSetProcess(TimeSetItem, canSave: Bool)
        case timeSetMemo(History)
        case timeSetEnd(History, canSave: Bool)
    }
    
    // MARK: - properties
    unowned var viewController: UIViewController!
    var dismiss: ((UIViewController, Bool) -> Void)?
    
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    @discardableResult
    func present(for route: Route) -> UIViewController? {
        guard case (let controller, var coordinator)? = get(for: route) else { return nil }
        var presentingViewController = controller
        // Set enable that navigation controller pop gesture recognizer before present
        viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        switch route {
        case let .dismiss(animated: animated):
            dismiss?(presentingViewController, animated)
            
        case .home:
            guard let mainViewController = viewController.navigationController?.viewControllers.first else { return nil }
            viewController.navigationController?.setViewControllers([mainViewController], animated: true)
        
        case .timeSetProcess(_):
            guard var viewControllers = viewController.navigationController?.viewControllers else { return nil }
            
            viewControllers.removeLast()
            viewControllers.append(presentingViewController)
            
            // Set dismiss handler
            coordinator.dismiss = popViewController
            viewController.navigationController?.setViewControllers(viewControllers, animated: false)

        case .timeSetEnd(_):
            // Wrap view to navigation container
            presentingViewController = BaseNavigationController(rootViewController: coordinator.viewController)
            fallthrough
            
        case .timeSetMemo(_):
            presentingViewController.modalPresentationStyle = .fullScreen
            
            // Set dismiss handler
            coordinator.dismiss = dismissViewController
            viewController.present(presentingViewController, animated: true)
        }
        
        return controller
    }
    
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)? {
        switch route {
        case .dismiss:
            return (viewController, self)
            
        case .home:
            return (viewController, self)
            
        case let .timeSetProcess(timeSetItem, canSave: canSave):
            let dependency = TimeSetProcessViewBuilder.Dependency(provider: provider, timeSetItem: timeSetItem, canSave: canSave)
            return TimeSetProcessViewBuilder(with: dependency).build()
            
        case let .timeSetMemo(history):
            let dependency = TimeSetMemoViewBuilder.Dependency(provider: provider, history: history)
            return TimeSetMemoViewBuilder(with: dependency).build()
            
        case let .timeSetEnd(history, canSave: canSave):
            let dependency = TimeSetEndViewBuilder.Dependency(provider: provider, history: history, canSave: canSave)
            return TimeSetEndViewBuilder(with: dependency).build()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
