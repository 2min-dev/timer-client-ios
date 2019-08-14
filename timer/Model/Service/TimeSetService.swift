//
//  TimerService.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

enum TimeSetEvent {
    case create
    case update
    case remove
}

protocol TimeSetServiceProtocol {
    var event: PublishSubject<TimeSetEvent> { get }
    var runningTimeSet: TimeSet? { get set }

    func fetchTimeSets() -> Single<[TimeSetInfo]>
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    func removeTimeSet(id: String) -> Single<TimeSetInfo>
}

/// A service class that manage the application's timers
class TimeSetService: BaseService, TimeSetServiceProtocol {
    enum TimeSetError: Error {
        case notExist
        case unknown
    }
    
    // MARK: - global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSetInfo] = []
    var runningTimeSet: TimeSet? // Running time set
    
    // MARK: - public method
    /// Fetch timer set list
    func fetchTimeSets() -> Single<[TimeSetInfo]> {
        return Single.create { emitter in
            emitter(.success(self.timeSets))
            return Disposables.create()
        }
    }
    
    /// Create a time set
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            guard let timeSet = info.copy() as? TimeSetInfo else {
                emitter(.error(TimeSetError.unknown))
                return Disposables.create()
            }
            // Create time set id
            let id = self.provider.userDefaultService.integer(.timeSetId)
            self.provider.userDefaultService.set(id + 1, key: .timeSetId)
            
            // Set id into time set and add time set
            timeSet.id = String(id)
            self.timeSets.append(timeSet)
            
            Logger.info("Time set created.")
            _ = JSONCodec.encode(timeSet)
            
            emitter(.success(timeSet))
            return Disposables.create()
        }
        .do(onSuccess: { _ in self.event.onNext(.create) })
    }
    
    // Update the time set
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            guard let timeSet = info.copy() as? TimeSetInfo, let id = info.id else {
                emitter(.error(TimeSetError.unknown))
                return Disposables.create()
            }

            guard let index = self.timeSets.firstIndex(where: { $0.id == id }) else {
                emitter(.error(TimeSetError.notExist))
                return Disposables.create()
            }
            // Update time set
            self.timeSets[index] = timeSet
            
            Logger.info("Time set updated.")
            _ = JSONCodec.encode(timeSet)
            
            emitter(.success(timeSet))
            return Disposables.create()
        }
        .do(onSuccess: { _ in self.event.onNext(.update) })
    }
    
    /// Delete the timerset
    func removeTimeSet(id: String) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            guard let index = self.timeSets.firstIndex(where: { $0.id == id }) else {
                emitter(.error(TimeSetError.notExist))
                return Disposables.create()
            }
            // Remove time set
            let timeSet = self.timeSets.remove(at: index)
            
            Logger.info("Time set deleted.")
            
            emitter(.success(timeSet))
            return Disposables.create()
        }
        .do(onSuccess: { _ in self.event.onNext(.remove) })
    }
}
