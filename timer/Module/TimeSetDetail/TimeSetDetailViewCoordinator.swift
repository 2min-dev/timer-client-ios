//
//  TimeSetDetailViewCoordinator.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetDetailViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum TimeSetDetailRoute {
        case home
        case timeSetEdit(TimeSetInfo)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetDetailViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetDetailRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .home:
            self.viewController.navigationController?.setViewControllers([viewController], animated: true)
        case .timeSetEdit(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: TimeSetDetailRoute) -> UIViewController? {
        switch route {
        case .home:
            return self.viewController.navigationController?.viewControllers.first
        case let .timeSetEdit(timeSetInfo):
            guard let copiedTimeSetInfo = timeSetInfo.copy() as? TimeSetInfo else { return nil }
            
            let coordinator = TimeSetEditViewCoordinator(provider: provider)
            let reactor = TimeSetEditViewReactor(timeSetService: provider.timeSetService, timeSetInfo: copiedTimeSetInfo)
            let viewController = TimeSetEditViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
