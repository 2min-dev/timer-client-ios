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
}

class AppService: AppServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    
    init() {
    
    }
}
