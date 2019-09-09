//
//  LocalTimeSetViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from local time set view
class LocalTimeSetViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum LocalTimeSetRoute {
        case timeSetDetail(TimeSetInfo)
    }
    
    // MARK: - properties
    weak var viewController: LocalTimeSetViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: LocalTimeSetRoute) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetDetail(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: LocalTimeSetRoute) -> UIViewController? {
        switch route {
        case let .timeSetDetail(timeSetInfo):
            let coordinator = TimeSetDetailViewCoordinator(provider: provider)
            let reactor = TimeSetDetailViewReactor(timeSetService: provider.timeSetService, timeSetInfo: timeSetInfo)
            let viewController = TimeSetDetailViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
