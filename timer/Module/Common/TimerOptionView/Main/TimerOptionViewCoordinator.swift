//
//  TimerOptionViewCoordinator.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimerOptionViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case alarmChange(String)
    }
    
    // MARK: - properties
    weak var viewController: TimerOptionViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: Route) -> UIViewController? {
        guard let viewController = get(for: route) else { return nil }
        
        switch route {
        case .alarmChange(_):
            self.viewController.navigationController?.pushViewController(viewController, animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case let .alarmChange(alarm):
            let viewController = AlarmChangeViewController()
            let reactor = AlarmChangeViewReactor(alarm: alarm)
            
            // DI
            viewController.reactor = reactor
            
            return viewController
        }
    }
}
