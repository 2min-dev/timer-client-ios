//
//  AppService.swift
//  timer
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum AppEvent {
    
}

protocol AppServicePorotocol {
    var event: PublishSubject<AppEvent> { get }
    
    func setCountdown(_ countdown: Int)
    func getCountdown() -> Int
}

class AppService: BaseService, AppServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    
    override init(provider: ServiceProviderProtocol) {
        super.init(provider: provider)
        
        registerUserDefaultDomain()
    }
    
    // MARK: - private method
    private func registerUserDefaultDomain() {
        provider.userDefaultService.register(defaults: [
            .timeSetId: 1,
            .countdown: 5
        ])
    }
    
    // MARK: - public method
    func setCountdown(_ countdown: Int) {
        provider.userDefaultService.set(countdown, key: .countdown)
    }
    
    func getCountdown() -> Int {
        return provider.userDefaultService.integer(.countdown)
    }
}
