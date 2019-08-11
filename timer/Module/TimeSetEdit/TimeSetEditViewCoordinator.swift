//
//  TimeSetEditViewCoordinator.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEditViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum TimeSetEditRoute {
        case timerOption
        case timeSetSave(TimeSetInfo)
    }
    
    // MARK: - properties
    weak var viewController: TimeSetEditViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: TimeSetEditRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetSave(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: TimeSetEditRoute) -> UIViewController? {
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
        case let .timeSetSave(timeSetInfo):
            let coordinator = TimeSetSaveViewCoordinator(provider: provider)
            let reactor = TimeSetSaveViewReactor(timeSetService: provider.timerService, timeSetInfo: timeSetInfo)
            let viewController = TimeSetSaveViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
