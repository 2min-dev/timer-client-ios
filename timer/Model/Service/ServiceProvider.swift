//
//  ServiceProvider.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

protocol ServiceProviderProtocol: class {
    var appService: AppServicePorotocol { get }
    var timerService: TimeSetServicePorotocol { get }
    var userDefaultService: UserDefaultServiceProtocol { get }
}

class ServiceProvider: ServiceProviderProtocol {
    lazy var appService: AppServicePorotocol = AppService()
    lazy var timerService: TimeSetServicePorotocol = TimeSetService()
    lazy var userDefaultService: UserDefaultServiceProtocol = UserDefaultService()
}
