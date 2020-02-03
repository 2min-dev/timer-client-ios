//
//  ServiceProvider.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

protocol ServiceProviderProtocol: class {
    var notificationService: NotificationServiceProtocol { get }
    var userDefaultService: UserDefaultServiceProtocol { get }
    var databaseService: DatabaseServiceProtocol { get }
    var networkService: NetworkServiceProtocol { get }
    
    var appService: AppServiceProtocol { get }
    var timeSetService: TimeSetServiceProtocol { get }
    var historyService: HistoryServiceProtocol { get }
}

class ServiceProvider: ServiceProviderProtocol {
    lazy var notificationService: NotificationServiceProtocol = NotificationService()
    lazy var userDefaultService: UserDefaultServiceProtocol = UserDefaultService()
    lazy var databaseService: DatabaseServiceProtocol = RealmService()
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    lazy var appService: AppServiceProtocol = AppService(userDefault: userDefaultService, network: networkService)
    lazy var timeSetService: TimeSetServiceProtocol = TimeSetService(database: databaseService, userDefault: userDefaultService, app: appService)
    lazy var historyService: HistoryServiceProtocol = HistoryService(database: databaseService, timeSet: timeSetService)
}
