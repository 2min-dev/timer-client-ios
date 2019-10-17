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
    func fetchTimeSets() -> Single<[TimeSetInfo]>
    
    /// Save a time set
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
    /// Remove the time set by id
    func removeTimeSet(id: String) -> Single<TimeSetInfo>
    
    /// Remove time set list
    func removeTimeSets(ids: [String]) -> Single<[TimeSetInfo]>
    
    /// Update the time set info
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo>
    
    /// Update time set list
    func updateTimeSets(infoes: [TimeSetInfo]) -> Single<[TimeSetInfo]>
    
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
