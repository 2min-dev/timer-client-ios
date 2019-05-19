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
        
    }

    // MARK: properties
    weak var rootViewController: ProductivityViewController!
    let provider: ServiceProviderProtocol
    
    required init(provider: ServiceProviderProtocol, rootViewController: ProductivityViewController) {
        self.provider = provider
        self.rootViewController = rootViewController
    }
    
    func present(for route: ProductivityRoute) {
        
    }
}
