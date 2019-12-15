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
        case dismiss
        case home
        case timeSetProcess(TimeSetItem, canSave: Bool)
        case timeSetMemo(History)
        case timeSetEnd(History, canSave: Bool)
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
        var presentingViewController = controller
        // Set enable that navigation controller pop gesture recognizer before present
        viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        switch route {
        case .dismiss:
            dismiss?(presentingViewController)
            
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
            presentingViewController = BaseNavicationController(rootViewController: coordinator.viewController)
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
            let coordinator = TimeSetProcessViewCoordinator(provider: provider)
            guard let reactor = TimeSetProcessViewReactor(appService: provider.appService, timeSetService: provider.timeSetService, timeSetItem: timeSetItem, canSave: canSave) else { return nil }
            let viewController = TimeSetProcessViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .timeSetMemo(history):
            let coordinator = TimeSetMemoViewCoordinator(provider: provider)
            let reactor = TimeSetMemoViewReactor(history: history)
            let viewController = TimeSetMemoViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
            
        case let .timeSetEnd(history, canSave: canSave):
            let coordinator = TimeSetEndViewCoordinator(provider: provider)
            let reactor = TimeSetEndViewReactor(timeSetService: provider.timeSetService, history: history, canSave: canSave)
            let viewController = TimeSetEndViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return (viewController, coordinator)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
