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
    
    func getCountdown() -> Int
}

class AppService: BaseService, AppServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    
    // MARK: - public method
    func getCountdown() -> Int {
        return provider.userDefaultService.integer(.countdown)
    }
}
