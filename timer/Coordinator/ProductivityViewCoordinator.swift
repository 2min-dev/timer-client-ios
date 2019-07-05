//
//  ProductivityViewCoordinator.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// Route from one touch timer view
class ProductivityViewCoordinator: CoordinatorProtocol {
     // MARK: route enumeration
    enum ProductivityRoute {
        case createTimerSet(TimerSet)
    }

    // MARK: properties
    weak var rootViewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: ProductivityViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: ProductivityRoute) {
        switch route {
        case let .createTimerSet(timerSet):
            Logger.verbose("presenting create timer set view controller.")
            
            let viewController = CreateTimerSetViewController()
            let coordinator = CreateTimerSetViewCoordinator(provider: provider, rootViewController: viewController)
            
            // DI
            viewController.coordinator = coordinator
            viewController.reactor = CreateTimerSetViewReactor(timerService: provider.timerService, timerSet: timerSet)
            
            // Hide tab bar when enter view controller
            viewController.hidesBottomBarWhenPushed = true
            
            // Push view controller
            rootViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
