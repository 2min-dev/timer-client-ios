//
//  AppService.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 14/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum AppEvent {
    case isLaboratoryOpened
}

protocol AppServicePorotocol {
    var event: PublishSubject<AppEvent> { get }
    
    func isLaboratoryOpened() -> Observable<Bool>
    func setLaboratoryOpened(_ isLaboratoryOpened: Bool)
}

class AppService: AppServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    private var laboratoryOpened: Bool
    
    init() {
        laboratoryOpened = UserDefaults.standard.bool(forKey: "laboratoryOpened")
    }
    
    func isLaboratoryOpened() -> Observable<Bool> {
        return Observable.just(laboratoryOpened)
    }
    
    func setLaboratoryOpened(_ isLaboratoryOpened: Bool) {
        laboratoryOpened = isLaboratoryOpened
        UserDefaults.standard.set(isLaboratoryOpened, forKey: "laboratoryOpened")
        
        event.onNext(.isLaboratoryOpened)
    }
}
