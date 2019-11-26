//
//  BaseService.swift
//  timer
//
//  Created by JSilver on 11/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class BaseService {
    // MARK: - properties
    unowned let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
}
