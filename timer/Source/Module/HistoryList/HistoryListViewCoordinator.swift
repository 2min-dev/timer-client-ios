//
//  HistoryListViewCoordinator.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryListViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum Route {
        case productivity
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
        case .productivity:
            guard let mainViewController = viewController as? MainViewController else { return nil }
            // Select productivity tab
            mainViewController.select(at: MainViewController.TabType.productivity.rawValue, animated: false)
            self.viewController.navigationController?.setViewControllers([viewController], animated: true)
        }
        
        return viewController
    }
    
    func get(for route: Route) -> UIViewController? {
        switch route {
        case .productivity:
            return self.viewController.navigationController?.viewControllers.first
        }
    }
}
