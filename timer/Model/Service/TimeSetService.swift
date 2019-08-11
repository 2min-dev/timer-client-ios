//
//  TimerService.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum TimeSetEvent {
    
}

protocol TimeSetServicePorotocol {
    var event: PublishSubject<TimeSetEvent> { get }
    
    func fetchTimeSets() -> Single<[TimeSetInfo]>
    func addTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    func removeTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
}

/// A service class that manage the application's timers
class TimeSetService: TimeSetServicePorotocol {
    // MARK: global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSetInfo] = []
    
    // MARK: - constructor
    init() {
        
    }
    
    // MARK: - public method
    /// Fetch timer set list
    func fetchTimeSets() -> Single<[TimeSetInfo]> {
        return Single.create { emitter in
            emitter(.success(self.timeSets))
            return Disposables.create()
        }
    }
    
    /// Create a timer set
    func addTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            guard let timeSet = info.copy() as? TimeSetInfo else {
                emitter(.error(RxError.unknown))
                return Disposables.create()
            }

            if let index = self.timeSets.firstIndex(where: { $0 === info }) {
                // Already exist time set
                self.timeSets[index] = timeSet
            } else {
                // New time set
                self.timeSets.append(timeSet)
            }
            emitter(.success(timeSet))
            
            return Disposables.create()
        }
    }
    
    /// Delete the timer set
    func removeTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            guard let index = self.timeSets.firstIndex(where: { $0 === info }) else {
                emitter(.error(RxError.unknown))
                return Disposables.create()
            }

            let timeSet = self.timeSets.remove(at: index)
            emitter(.success(timeSet))
            
            return Disposables.create()
        }
    }
}
