//
//  OpenSourceLicenseViewReactor.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class OpenSourceLicenseViewReactor: Reactor {
    enum Action {
        /// Read opensource liscense notice text when view did load
        case viewDidLoad
    }
    
    enum Mutation {
        /// Set opensource license notice
        case setLicense(String?)
    }
    
    struct State {
        /// Opensource liscense notice
        var license: String?
    }
    
    // MARK: - properties
    var initialState: State
    
    // MARK: - constructor
    init() {
        initialState = State(license: "")
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return actionViewDidLoad()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setLicense(license):
            state.license = license
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewDidLoad() -> Observable<Mutation> {
        /// Read opensource notice text file from bundle
        guard let path = Bundle.main.path(forResource: "OPENSOURCE", ofType: "html") else { return .empty() }
        let license = try? String(contentsOfFile: path, encoding: .utf8)
        
        return .just(.setLicense(license))
    }
    
    deinit {
        Logger.verbose()
    }
}
