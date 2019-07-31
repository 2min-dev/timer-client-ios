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
     // MARK: route enumeration
    enum ProductivityRoute {
        case timerOption
        case timeSetEdit(TimeSetInfo)
    }

    // MARK: properties
    weak var rootViewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: ProductivityViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: ProductivityRoute) -> UIViewController {
        let viewController = get(for: route)
        switch route {
        case .timeSetEdit(_):
            rootViewController.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: ProductivityRoute) -> UIViewController {
        switch route {
        case .timerOption:
            let viewController = TimerOptionViewController()
            
            // DI
            viewController.reactor = TimerOptionViewReactor()
            viewController.coordinator = TimerOptionViewCoordinator(provider: provider, rootViewController: viewController)
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            
            return navigationController
        case let .timeSetEdit(timeSetInfo):
            let viewController = TimeSetEditViewController()
            
            // DI
            viewController.reactor = TimeSetEditViewReactor(timeSetInfo: timeSetInfo)
            viewController.coordinator = TimeSetEditViewCoordinator(provider: provider, rootViewController: viewController)
            
            return viewController
        }
    }
}
