//
//  CoordinatorProtocol.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

protocol CoordinatorProtocol: class {
    associatedtype Route
    associatedtype ViewController
    
    var rootViewController: ViewController! { get }
    var provider: ServiceProviderProtocol { get }
    
    init(provider: ServiceProviderProtocol, rootViewController: ViewController)
    
    func present(for route: Route)
}
