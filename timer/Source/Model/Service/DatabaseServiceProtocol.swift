//
//  DatabaseServiceProtocol.swift
//  timer
//
//  Created by JSilver on 04/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

protocol DatabaseServiceProtocol {
    // MARK: - time set operate
    /// Fetch all time set list
    func fetchTimeSets() -> Single<[TimeSetItem]>
    
    /// Save a time set
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Remove the time set by id
    func removeTimeSet(id: String) -> Single<TimeSetItem>
    
    /// Remove time set list
    func removeTimeSets(ids: [String]) -> Single<[TimeSetItem]>
    
    /// Update the time set item
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Update time set list
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]>
    
    /// Fetch all history list
    func fetchHistories() -> Single<[History]>
    
    /// Save a history
    func createHistory(_ history: History) -> Single<History>
    
    /// Update the history
    func updateHistory(_ history: History) -> Single<History>
    
    // MARK: - database operate
    /// Clear database
    func clear()
}
