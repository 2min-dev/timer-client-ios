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
    /// Fetch a time set item from id
    func fetchTimeSet(id: Int) -> Single<TimeSetItem>
    
    /// Fetch all time set item list
    func fetchTimeSets() -> Single<[TimeSetItem]>
    
    /// Fetch recently used time set item list
    func fetchRecentlyUsedTimeSets(count: Int) -> Single<[TimeSetItem]>
    
    /// Create a time set
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Remove the time set
    func removeTimeSet(id: Int) -> Single<TimeSetItem>
    
    /// Remove time set list
    func removeTimeSets(ids: [Int]) -> Single<[TimeSetItem]>
    
    /// Update the time set
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Update time set list
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]>
    
    /// Store current running time set data into user defaults
    func storeTimeSet()
    
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
class TimeSetService: TimeSetServiceProtocol {
    // MARK: - global state event
    var event: PublishSubject<TimeSetEvent> = PublishSubject()
    
    // MARK: - properties
    private var databaseService: DatabaseServiceProtocol
    private var userDefaultService: UserDefaultServiceProtocol
    private var appService: AppServiceProtocol
    
    private var timeSets: [TimeSetItem]?
    var runningTimeSet: RunningTimeSet? {
        didSet {
            guard let timeSet = runningTimeSet?.timeSet else { return }
            disposeBag = DisposeBag()
            
            // Bind time set event
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
    
    // MARK: - constructor
    init(database: DatabaseServiceProtocol, userDefault: UserDefaultServiceProtocol, app: AppServiceProtocol) {
        databaseService = database
        userDefaultService = userDefault
        appService = app
    }
    
    // MARK: - private method
    /// Generate time set id
    private func generateTimeSetId() -> Int {
        // Get last time set identifier
        let id = userDefaultService.integer(.timeSetId)
        // Increase last time set identifier
        userDefaultService.set(id + 1, key: .timeSetId)
        
        return id
    }
    
    // MARK: - public method
    // MARK: - time set
    func fetchTimeSet(id: Int) -> Single<TimeSetItem> {
        provider.databaseService.fetchTimeSet(id: id)
            .do(onSuccess: { $0.reset() })
    }
    
    func fetchTimeSets() -> Single<[TimeSetItem]> {
        Logger.info("fetch time set list", tag: "SERVICE")
        
        if let timeSets = self.timeSets {
            return .just(timeSets)
        } else {
            return databaseService.fetchTimeSets()
                .do(onSuccess: { self.timeSets = $0 })
        }
    }
    
    func fetchRecentlyUsedTimeSets(count: Int) -> Single<[TimeSetItem]> {
        provider.databaseService.fetchRecentlyUsedTimeSets(count: count)
            .do(onSuccess: { $0.forEach { $0.reset() } })
    }
    
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        // Set time set id
        item.id = generateTimeSetId()
        item.isSaved = true
        
        return databaseService.createTimeSet(item: item)
            .flatMap { timeSet in
                self.databaseService.fetchTimeSets()
                    .do(onSuccess: { self.timeSets = $0 })
                    .map { _ in timeSet }
            }
            .do(onSuccess: { _ in
                Logger.info("a time set created.", tag: "SERVICE")
                self.event.onNext(.created)
            })
    }
    
    func removeTimeSet(id: Int) -> Single<TimeSetItem> {
        fetchTimeSets()
            .flatMap {
                // Check is time set exist
                guard $0.firstIndex(where: { $0.id == id }) != nil else { return .error(TimeSetError.notFound) }
                return self.provider.databaseService.removeTimeSet(id: id)
            }
            .flatMap { removedTimeSet in
                self.databaseService.fetchTimeSets()
                    .do(onSuccess: { self.timeSets = $0 })
                    .map { _ in removedTimeSet }
            }
            .do(onSuccess: { _ in
                Logger.info("the time set removed.", tag: "SERVICE")
                self.event.onNext(.removed)
            })
    }
    
    func removeTimeSets(ids: [Int]) -> Single<[TimeSetItem]> {
        self.provider.databaseService.removeTimeSets(ids: ids)
            .flatMap { removedTimeSets in
                self.provider.databaseService.fetchTimeSets()
                    .do(onSuccess: { self.timeSets = $0 })
                    .map { _ in removedTimeSets }
            }
            .do(onSuccess: { _ in
                Logger.info("time set list removed.", tag: "SERVICE")
                self.event.onNext(.removed)
            })
    }
    
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        fetchTimeSets()
            .flatMap { timeSets in
                guard timeSets.firstIndex(where: { $0.id == item.id }) != nil else { return .error(TimeSetError.notFound) }
                return self.databaseService.updateTimeSet(item: item)
            }
            .flatMap { updatedTimeSet in
                self.databaseService.fetchTimeSets()
                    .do(onSuccess: { self.timeSets = $0 })
                    .map { _ in updatedTimeSet }
            }
            .do(onSuccess: { _ in
                Logger.info("the time set updated.", tag: "SERVICE")
                self.event.onNext(.updated)
            })
    }
    
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]> {
        self.databaseService.updateTimeSets(items: items)
            .flatMap { updatedTimeSets in
                self.databaseService.fetchTimeSets()
                    .do(onSuccess: { self.timeSets = $0 })
                    .map { _ in updatedTimeSets }
            }
            .do(onSuccess: { _ in
                Logger.info("time set list updated.", tag: "SERVICE")
                self.event.onNext(.updated)
            })
    }
    
    func storeTimeSet() {
        // Create running time set object and store into user defaults
        appService.setRunningTimeSet(runningTimeSet)
    }
    
    func restoreTimeSet() -> TimeSet? {
        let runningTimeSet = appService.getRunningTimeSet()
        appService.setRunningTimeSet(nil)
        
        guard runningTimeSet != nil else { return nil }
        
        if self.runningTimeSet == nil {
            // Resotre running time set from user defaults
            self.runningTimeSet = runningTimeSet
        }
        
        return self.runningTimeSet?.timeSet
    }
    
    // MARK: - history
    func fetchHistories() -> Single<[History]> {
        return databaseService.fetchHistories(pagination: nil)
    }
    
    func createHistory(_ history: History) -> Single<History> {
        // Set time set id of history
        let timeSetId = generateTimeSetId()
        
        history.item?.id = timeSetId
        history.item?.isSaved = false
        
        if history.originId < 0 {
            // Set history to refer time set itself
            history.originId = timeSetId
        }
        
        return provider.databaseService.createHistory(history)
            .do(onSuccess: { _ in Logger.info("a history created.", tag: "SERVICE") })
    }
    
    func updateHistory(_ history: History) -> Single<History> {
        return databaseService.updateHistory(history)
            .do(onSuccess: { _ in Logger.info("the history updated.", tag: "SERVICE") })
    }
}
