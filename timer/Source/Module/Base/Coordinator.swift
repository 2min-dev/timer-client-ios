//
//  Coordinator.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

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
    var dismiss: ((UIViewController) -> Void)? { get set }
}

extension ViewCoordinatorType {
    var popViewController: (UIViewController) -> Void {
        {
            guard var viewControllers = $0.navigationController?.viewControllers,
                let index = viewControllers.firstIndex(of: $0) else { return }
            viewControllers.remove(at: index)
            $0.navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    
    var dismissViewController: (UIViewController) -> Void {
        {
            $0.dismiss(animated: true)
        }
    }
}

typealias LaunchCoordinator = LaunchCoordinatorType & Routable
typealias ViewCoordinator = ViewCoordinatorType & Routable

protocol ViewControllable where Self: UIViewController {
    associatedtype Coordinator: ViewCoordinator
    var coordinator: Coordinator { get }
}

protocol ServiceContainer {
    var provider: ServiceProviderProtocol { get }
}
