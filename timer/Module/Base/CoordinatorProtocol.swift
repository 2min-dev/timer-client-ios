//
//  CoordinatorProtocol.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

protocol CoordinatorProtocol: class {
    associatedtype Route
    associatedtype ViewController
    
    var viewController: ViewController! { get }
    var provider: ServiceProviderProtocol { get }
    
    init(provider: ServiceProviderProtocol)
    
    func present(for route: Route) -> UIViewController
    func get(for route: Route) -> UIViewController
}
