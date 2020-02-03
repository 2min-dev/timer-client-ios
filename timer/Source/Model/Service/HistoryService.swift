//
//  HistoryService.swift
//  timer
//
//  Created by JSilver on 2020/02/02.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import RxSwift

protocol HistoryServiceProtocol {
    /// Fetch all history list
    func fetchHistories() -> Single<[History]>
    
    /// Create a history
    func createHistory(_ history: History) -> Single<History>
    
    /// Update a history
    func updateHistory(_ history: History) -> Single<History>
}

class HistoryService: HistoryServiceProtocol {
    // MARK: - properties
    private var databaseService: DatabaseServiceProtocol
    private var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(database: DatabaseServiceProtocol, timeSet: TimeSetServiceProtocol) {
        databaseService = database
        timeSetService = timeSet
    }
    
    // MARK: - history
    func fetchHistories() -> Single<[History]> {
        databaseService.fetchHistories(pagination: nil)
    }
    
    func createHistory(_ history: History) -> Single<History> {
        // Set time set id of history
        history.item?.id = timeSetService.getTimeSetId()
        history.item?.isSaved = false
        
        return databaseService.createHistory(history)
            .do(onSuccess: { _ in Logger.info("a history created.", tag: "SERVICE") })
    }
    
    func updateHistory(_ history: History) -> Single<History> {
        databaseService.updateHistory(history)
            .do(onSuccess: { _ in Logger.info("the history updated.", tag: "SERVICE") })
    }
}
