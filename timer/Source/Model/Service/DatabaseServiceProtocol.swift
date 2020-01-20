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
    /// - returns: A observable that emit all time set item list
    func fetchTimeSets() -> Single<[TimeSetItem]>
    
    /// Create a time set
    /// - parameters:
    ///   - item: data of the time set
    /// - returns: A observable that emit a created time set item
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Remove the time set
    /// - parameters:
    ///   - id: Identifier of the time set to remove
    /// - returns: A observable that emit a removed time set item
    func removeTimeSet(id: Int) -> Single<TimeSetItem>
    
    /// Remove time set list
    /// - parameters:
    ///   - ids: Identifier list of the time set list to remove
    /// - returns: A observable that emit all removed time set item list
    func removeTimeSets(ids: [Int]) -> Single<[TimeSetItem]>
    
    /// Update the time set
    /// - parameters:
    ///   - item: data of the time set
    /// - returns: A observable that emit a updated time set item
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem>
    
    /// Update time set list
    /// - parameters:
    ///   - items: data list of the time set
    /// - returns: A observable that emit all updated time set item list
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]>
    
    /// Fetch all hisotry list
    /// - returns: A observable that emit all history list
    func fetchHistories(pagination: PaginationParam?) -> Single<[History]>
    
    /// Fetch history list that refer origin time set item id
    /// - parameters:
    ///   - id: Identifier of original time set item of history
    /// - returns: A observable that emit all history list that refer origin time set item id
    func fetchHistories(origin id: Int) -> Single<[History]>
    
    /// Fetch history list that refer origin time set item id
    /// - parameters:
    ///   - ids: Identifier list of original time set item of history
    /// - returns: A observable that emit all history list that refer origin time set item id
    func fetchHistories(origin ids: [Int]) -> Single<[History]>
    
    /// Create a history
    /// - parameters:
    ///   - history: data of the history
    /// - returns: A observable that emit a created history
    func createHistory(_ history: History) -> Single<History>
    
    /// Update the history
    /// - parameters:
    ///   - history: data of the history
    /// - returns: A observable that emit a updated hisotry
    func updateHistory(_ history: History) -> Single<History>
    
    /// Update history list
    /// - parameters:
    ///   - histories: data list of the history
    /// - returns: A observable that emit all updated history list
    func updateHistories(_ histories: [History]) -> Single<[History]>
    
    // MARK: - database operate
    /// Clear database
    func clear()
}
