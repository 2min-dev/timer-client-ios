//
//  ServiceProvider.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

protocol ServiceProviderProtocol: class {
    var appService: AppServicePorotocol { get }
    var timerService: TimerSetServicePorotocol { get }
}

class ServiceProvider: ServiceProviderProtocol {
    lazy var appService: AppServicePorotocol = AppService()
    lazy var timerService: TimerSetServicePorotocol = TimerSetService()
}
