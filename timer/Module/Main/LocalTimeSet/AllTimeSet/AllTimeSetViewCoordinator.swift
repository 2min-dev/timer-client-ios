//
//  AllTimeSetViewCoordinator.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AllTimeSetViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case timeSetDetail(TimeSetInfo)
    }
    
    // MARK: - properties
    weak var viewController: UIViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .timeSetDetail(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
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
