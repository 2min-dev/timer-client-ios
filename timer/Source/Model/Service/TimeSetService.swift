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
    /// A time set created
    case created
    
    /// The time set updated
    case updated
    
    /// The time set removed
    case removed
}

protocol TimeSetServiceProtocol {
    var event: PublishSubject<TimeSetEvent> { get }
    
    /// Current running time set
    var runningTimeSet: RunningTimeSet? { get set }
    
    // MARK: - time set
    /// Fetch all time set info list
    func fetchTimeSets() -> Single<[TimeSetInfo]>
    
    /// Create a time set
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
    /// Remove the time set
    func removeTimeSet(id: String) -> Single<TimeSetInfo>
    
    /// Remove time set list
    func removeTimeSets(ids: [String]) -> Single<[TimeSetInfo]>
    
    /// Update the time set
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
    /// Update time set list
    func updateTimeSets(infoes: [TimeSetInfo]) -> Single<[TimeSetInfo]>
    
    /// Store current running time set data into user defaults
    func storeTimeSet() -> TimeSet?
    
    /// Restore and set current running time set from user defaults
    func restoreTimeSet() -> TimeSet?
    
    // MARK: - history
    /// Fetch all history list
    func fetchHistories() -> Single<[History]>
    
    /// Create a history
    func createHistory(_ history: History) -> Single<History>
    
    /// Update a history
    func updateHistory(_ history: History) -> Single<History>
}

/// A service class that manage the application's timers
class TimeSetService: BaseService, TimeSetServiceProtocol {
    // MARK: - global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSetInfo]?
    var runningTimeSet: RunningTimeSet?
    
    // MARK: - public method
    // MARK: - time set
    func fetchTimeSets() -> Single<[TimeSetInfo]> {
        Logger.info("fetch time set list", tag: "SERVICE")
        
        if let timeSets = self.timeSets {
            return .just(timeSets)
        } else {
            return provider.databaseService.fetchTimeSets()
                .do(onSuccess: { timeSets in
                    self.timeSets = timeSets
                })
        }
    }
    
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        // Create time set id
        let id = provider.userDefaultService.integer(.timeSetId)
        info.id = String(id)
        
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                
                // Save into realm
                return self.provider.databaseService.createTimeSet(info: info)
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
                        self.timeSets = timeSets
                        
                        Logger.info("the time set removed.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.removed) })
    }
    
    func removeTimeSets(ids: [String]) -> Single<[TimeSetInfo]> {
        return self.provider.databaseService.removeTimeSets(ids: ids)
            .flatMap { removedTimeSets -> Single<[TimeSetInfo]> in
                return self.provider.databaseService.fetchTimeSets()
                    .do(onSuccess: {
                        // Update time set list
                        self.timeSets = $0
                        Logger.info("time set list removed.", tag: "SERVICE")
                    })
                    .flatMap { _ in .just(removedTimeSets)}
        }
        .do(onSuccess: { _ in self.event.onNext(.removed) })
    }
    
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                guard let id = info.id, let index = timeSets.firstIndex(where: { $0.id == id }) else { return .error(TimeSetError.notFound) }
                
                return self.provider.databaseService.updateTimeSet(info: info)
                    .do(onSuccess: {
                        // Update time set
                        timeSets[index] = $0
                        self.timeSets = timeSets
                        
                        Logger.info("the time set updated.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.updated) })
    }
    
    func updateTimeSets(infoes: [TimeSetInfo]) -> Single<[TimeSetInfo]> {
        return self.provider.databaseService.updateTimeSets(infoes: infoes)
            .flatMap { updatedTimeSets -> Single<[TimeSetInfo]> in
                return self.provider.databaseService.fetchTimeSets()
                    .do(onSuccess: {
                        // Update time set list
                        self.timeSets = $0
                        Logger.info("time set list updated.", tag: "SERVICE")
                    })
                    .flatMap { _ in .just(updatedTimeSets) }
        }
        .do(onSuccess: { _ in self.event.onNext(.updated) })
    }
    
    func storeTimeSet() -> TimeSet? {
        guard let runningTimeSet = runningTimeSet,
            case .run(detail: _) = runningTimeSet.timeSet.state else {
                provider.appService.setRunningTimeSet(nil)
                return nil
        }
        
        // Create running time set object and store into user defaults
        provider.appService.setRunningTimeSet(runningTimeSet)
        
        return runningTimeSet.timeSet
    }
    
    func restoreTimeSet() -> TimeSet? {
        // Resotre running time set from user defaults
        runningTimeSet = provider.appService.getRunningTimeSet()
        return runningTimeSet?.timeSet
    }
    
    // MARK: - history
    func fetchHistories() -> Single<[History]> {
        return provider.databaseService.fetchHistories()
    }
    
    func createHistory(_ history: History) -> Single<History> {
        // Create history's time set id
        let id = provider.userDefaultService.integer(.timeSetId)
        history.info?.id = String(format: "H%d", id)
        
        return provider.databaseService.createHistory(history)
            .do(onSuccess: { _ in
                // Update time set id
                self.provider.userDefaultService.set(id + 1, key: .timeSetId)
                Logger.info("a history created.", tag: "SERVICE")
            })
    }
    
    func updateHistory(_ history: History) -> Single<History> {
        return provider.databaseService.updateHistory(history)
            .do(onSuccess: { _ in
                history.startDate = Date()
            })
            .do(onSuccess: { _ in Logger.info("the history updated.", tag: "SERVICE") })
    }
}
