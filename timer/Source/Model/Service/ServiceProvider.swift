//
//  ServiceProvider.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

protocol ServiceProviderProtocol: class {
    var appService: AppServiceProtocol { get }
    var userDefaultService: UserDefaultServiceProtocol { get }
    var databaseService: DatabaseServiceProtocol { get }
    var networkService: NetworkServiceProtocol { get }
    var timeSetService: TimeSetServiceProtocol { get }
}

class ServiceProvider: ServiceProviderProtocol {
    lazy var appService: AppServiceProtocol = AppService(provider: self)
    lazy var userDefaultService: UserDefaultServiceProtocol = UserDefaultService(provider: self)
    lazy var databaseService: DatabaseServiceProtocol = RealmService(provider: self)
    lazy var networkService: NetworkServiceProtocol = NetworkService(provider: self)
    lazy var timeSetService: TimeSetServiceProtocol = TimeSetService(provider: self)
}
