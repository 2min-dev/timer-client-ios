//
//  ProductivityViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from one touch timer view
class ProductivityViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum ProductivityRoute {
        case timerOption
        case timeSetEdit(TimeSetInfo)
    }

    // MARK: - properties
    weak var viewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: ProductivityRoute) -> UIViewController {
        let viewController = get(for: route)
        switch route {
        case .timeSetEdit(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: ProductivityRoute) -> UIViewController {
        switch route {
        case .timerOption:
            let coordinator = TimerOptionViewCoordinator(provider: provider)
            let reactor = TimerOptionViewReactor()
            let viewController = TimerOptionViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            
            return navigationController
        case let .timeSetEdit(timeSetInfo):
            let coordinator = TimeSetEditViewCoordinator(provider: provider)
            let reactor = TimeSetEditViewReactor(timeSetInfo: timeSetInfo)
            let viewController = TimeSetEditViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
