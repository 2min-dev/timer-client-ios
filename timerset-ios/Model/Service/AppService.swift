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
    
    func getIsLaboratoryOpened() -> Observable<Bool>
    func setIsLaboratoryOpened(isOpened: Bool)
}

class AppService: AppServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<AppEvent> = PublishSubject()
    
    // MARK: properties
    private var isLaboratoryOpened: Bool
    
    init() {
        isLaboratoryOpened = UserDefaults.standard.bool(forKey: "isLaboratoryOpened")
    }
    
    func getIsLaboratoryOpened() -> Observable<Bool> {
        return Observable.just(isLaboratoryOpened)
    }
    
    func setIsLaboratoryOpened(isOpened: Bool) {
        isLaboratoryOpened = isOpened
        UserDefaults.standard.set(isOpened, forKey: "isLaboratoryOpened")
        
        event.onNext(.isLaboratoryOpened)
    }
}
