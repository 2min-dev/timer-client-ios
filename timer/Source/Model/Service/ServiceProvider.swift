//
//  ServiceProvider.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

protocol ServiceProviderProtocol: class {
    var notificationService: NotificationServiceProtocol { get }
    var appService: AppServiceProtocol { get }
    var timeSetService: TimeSetServiceProtocol { get }
    var historyService: HistoryServiceProtocol { get }
}

class ServiceProvider: ServiceProviderProtocol {
    // MARK: - private service
    private lazy var userDefaultService: UserDefaultServiceProtocol = UserDefaultService()
    private lazy var databaseService: DatabaseServiceProtocol = RealmService()
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    // MARK: - public service
    lazy var notificationService: NotificationServiceProtocol = NotificationService()
    lazy var appService: AppServiceProtocol = AppService(userDefault: userDefaultService, network: networkService)
    lazy var timeSetService: TimeSetServiceProtocol = TimeSetService(network: networkService, database: databaseService, userDefault: userDefaultService, app: appService)
    lazy var historyService: HistoryServiceProtocol = HistoryService(database: databaseService, timeSet: timeSetService)
}
