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
    
    /// The running time set ended
    case ended(History)
}

protocol TimeSetServiceProtocol {
    var event: PublishSubject<TimeSetEvent> { get }
    
    /// Current running time set
    var runningTimeSet: RunningTimeSet? { get set }
    
    // MARK: - time set
    /// Fetch all time set item list
    func fetchTimeSets() -> Single<[TimeSetItem]>
    
    /// Create a time set
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Remove the time set
    func removeTimeSet(id: String) -> Single<TimeSetItem>
    
    /// Remove time set list
    func removeTimeSets(ids: [String]) -> Single<[TimeSetItem]>
    
    /// Update the time set
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Update time set list
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]>
    
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
    enum TimeSetType {
        case normal
        case history
        
        var prefix: String {
            switch self {
            case .normal:
                return ""
                
            case .history:
                return "H"
            }
        }
    }
    
    // MARK: - global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var timeSets: [TimeSetItem]?
    var runningTimeSet: RunningTimeSet? {
        didSet {
            guard let timeSet = storeTimeSet() else { return }
            disposeBag = DisposeBag()
            
            timeSet.event
                .compactMap {
                    switch $0 {
                    case .stateChanged(.end):
                        return timeSet.history
                        
                    default:
                        return nil
                    }
                }
                .subscribe(onNext: { [weak self] in self?.event.onNext(.ended($0)) })
                .disposed(by: disposeBag)
        }
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - private method
    /// Generate time set id
    private func generateTimeSetId(type: TimeSetType) -> String {
        // Get last time set identifier
        let id = provider.userDefaultService.integer(.timeSetId)
        // Increase last time set identifier
        provider.userDefaultService.set(id + 1, key: .timeSetId)
        
        return "\(type.prefix)\(id)"
    }
    
    // MARK: - public method
    // MARK: - time set
    func fetchTimeSets() -> Single<[TimeSetItem]> {
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
    
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        // Set time set id
        item.id = generateTimeSetId(type: .normal)
        
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                
                // Save into realm
                return self.provider.databaseService.createTimeSet(item: item)
                    .do(onSuccess: {
                        // Append item current time set list
                        timeSets.append($0)
                        self.timeSets = timeSets
                        
                        Logger.info("a time set created.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.created) })
    }
    
    func removeTimeSet(id: String) -> Single<TimeSetItem> {
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
    
    func removeTimeSets(ids: [String]) -> Single<[TimeSetItem]> {
        return self.provider.databaseService.removeTimeSets(ids: ids)
            .flatMap { removedTimeSets -> Single<[TimeSetItem]> in
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
    
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        return fetchTimeSets()
            .flatMap { timeSets in
                // Convert mutable array
                var timeSets = timeSets
                guard let id = item.id, let index = timeSets.firstIndex(where: { $0.id == id }) else { return .error(TimeSetError.notFound) }
                
                return self.provider.databaseService.updateTimeSet(item: item)
                    .do(onSuccess: {
                        // Update time set
                        timeSets[index] = $0
                        self.timeSets = timeSets
                        
                        Logger.info("the time set updated.", tag: "SERVICE")
                    })
        }
        .do(onSuccess: { _ in self.event.onNext(.updated) })
    }
    
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]> {
        return self.provider.databaseService.updateTimeSets(items: items)
            .flatMap { updatedTimeSets -> Single<[TimeSetItem]> in
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
    
    @discardableResult
    func storeTimeSet() -> TimeSet? {
        guard let runningTimeSet = runningTimeSet else {
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
        // Set time set id of history
        history.item?.id = generateTimeSetId(type: .history)
        
        return provider.databaseService.createHistory(history)
            .do(onSuccess: { _ in Logger.info("a history created.", tag: "SERVICE") })
    }
    
    func updateHistory(_ history: History) -> Single<History> {
        return provider.databaseService.updateHistory(history)
            .do(onSuccess: { _ in Logger.info("the history updated.", tag: "SERVICE") })
    }
}
