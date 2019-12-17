//
//  Coordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

// MARK: - coordinator
protocol Routable {
    associatedtype Route
    
    @discardableResult
    func present(for route: Route) -> UIViewController?
    func get(for route: Route) -> (controller: UIViewController, coordinator: ViewCoordinatorType)?
}

protocol LaunchCoordinatorType {
    var window: UIWindow { get }
}

protocol ViewCoordinatorType {
    var viewController: UIViewController! { get }
    var dismiss: ((UIViewController, Bool) -> Void)? { get set }
}

extension ViewCoordinatorType {
    var popViewController: (UIViewController, Bool) -> Void {
        return {
            guard var viewControllers = $0.navigationController?.viewControllers,
                let index = viewControllers.firstIndex(of: $0) else { return }
            viewControllers.remove(at: index)
            $0.navigationController?.setViewControllers(viewControllers, animated: $1)
        }
    }
    
    var dismissViewController: (UIViewController, Bool) -> Void {
        return { $0.dismiss(animated: $1) }
    }
}

typealias LaunchCoordinator = LaunchCoordinatorType & Routable
typealias ViewCoordinator = ViewCoordinatorType & Routable

// MARK: - view controller
protocol ViewControllable where Self: UIViewController {
    associatedtype Coordinator: ViewCoordinator
    var coordinator: Coordinator { get }
}

// MARK: - builder
protocol Builder {
    associatedtype Dependency
    
    var dependency: Dependency { get }
    
    init(with dependency: Dependency)
    func build() -> (UIViewController, ViewCoordinatorType)?
}

// MARK: - application
protocol ServiceContainer {
    var provider: ServiceProviderProtocol { get }
}
