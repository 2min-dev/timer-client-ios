//
//  TimerService.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RealmSwift

enum TimeSetEvent {
    /// Running time set state changed
    case timeSetChanged(TimeSet?)
    
    /// A time set created
    case created
    
    /// The time set updated
    case updated
    
    /// The time set removed
    case removed
}

protocol TimeSetServiceProtocol {
    var event: PublishSubject<TimeSetEvent> { get }
    
    // Running time set
    var runningTimeSetInfo: TimeSetInfo? { get }
    var runningTimeSet: TimeSet? { get }
    
    /// Set running time set
    func setRunningTimeSet(_ timeSet: TimeSet?, origin info: TimeSetInfo?)
    
    /// Fetch all time set infos
    func fetchTimeSets() -> Single<[TimeSetInfo]>
    
    /// Create a time set
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
    /// Remove the time set
    func removeTimeSet(id: String) -> Single<TimeSetInfo>
    
    /// Update the time set
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
}

/// A service class that manage the application's timers
class TimeSetService: BaseService, TimeSetServiceProtocol {
    // MARK: - global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSetInfo]?
    
    // Running time set original info
    var runningTimeSetInfo: TimeSetInfo?
    // Running time set
    var runningTimeSet: TimeSet? {
        didSet { event.onNext(.timeSetChanged(runningTimeSet)) }
    }
    
    // MARK: - public method
    func setRunningTimeSet(_ timeSet: TimeSet?, origin info: TimeSetInfo?) {
        runningTimeSet = timeSet
        runningTimeSetInfo = info
    }
    
    /// Fetch timer set list
    func fetchTimeSets() -> Single<[TimeSetInfo]> {
        if let timeSets = self.timeSets {
            return .just(timeSets)
        } else {
            return provider.databaseService.fetchTimeSets()
                .do(onSuccess: { timeSets in
                    self.timeSets = timeSets
                })
        }
    }
    
    /// Create a time set
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                guard let timeSet = info.copy() as? TimeSetInfo else { return .error(TimeSetError.unknown) }
                
                // Create time set id
                let id = self.provider.userDefaultService.integer(.timeSetId)
                timeSet.id = String(id)
                
                // Save into realm
                return self.provider.databaseService.createTimeSet(info: timeSet)
                    .do(onSuccess: {
                        // Append info current time set list
                        timeSets.append($0)
                        self.timeSets = timeSets
                        
                        // Update time set id
                        self.provider.userDefaultService.set(id + 1, key: .timeSetId)
                        
                        Logger.info("a time set created.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.created) })
    }
    
    // Update the time set
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                guard let timeSet = info.copy() as? TimeSetInfo, let id = info.id else { return .error(TimeSetError.unknown) }
                guard let index = timeSets.firstIndex(where: { $0.id == id }) else { return .error(TimeSetError.notFound) }
                
                return self.provider.databaseService.updateTimeSet(id: id, info: timeSet)
                    .do(onSuccess: {
                        // Update time set
                        timeSets[index] = $0
                        self.timeSets = timeSets
                        
                        Logger.info("the time set updated.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.updated) })
    }
    
    /// Delete the timerset
    func removeTimeSet(id: String) -> Single<TimeSetInfo> {
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                guard let index = timeSets.firstIndex(where: { $0.id == id }) else { return .error(TimeSetError.notFound) }
                
                return self.provider.databaseService.removeTimeSet(id: id)
                    .do(onSuccess: { _ in
                        // Remove time set
                        timeSets.remove(at: index)
                        
                        Logger.info("the time set removed.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.removed) })
    }
}
