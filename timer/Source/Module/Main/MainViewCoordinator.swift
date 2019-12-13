//
//  MainViewCoordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

/// Route from main view (tab bar)
class MainViewCoordinator: CoordinatorProtocol {
     // MARK: - route enumeration
    enum Route {
        case productivity
        case local
        case preset
        case historyDetail(History)
    }
    
    weak var viewController: MainViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .historyDetail(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
            
        default:
            break
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .productivity:
            let coordinator = ProductivityViewCoordinator(provider: provider)
            let reactor = TimeSetEditViewReactor(appService: provider.appService, timeSetService: provider.timeSetService)
            let viewController = ProductivityViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .local:
            let coordinator = LocalTimeSetViewCoordinator(provider: provider)
            let reactor = LocalTimeSetViewReactor(timeSetService: provider.timeSetService)
            let viewController = LocalTimeSetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case .preset:
            let coordinator = PresetViewCoordinator(provider: provider)
            let reactor = PresetViewReactor(networkService: provider.networkService)
            let viewController = PresetViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
            
        case let .historyDetail(history):
            let coordinator = HistoryDetailViewCoordinator(provider: provider)
            let reactor = HistoryDetailViewReactor(timeSetService: provider.timeSetService, history: history)
            let viewController = HistoryDetailViewController(coordinator: coordinator)
            
            // DI
            coordinator.viewController = viewController
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
