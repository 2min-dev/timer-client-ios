//
//  PresetViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

class PresetViewReactor: Reactor {
    // MARK: - constants
    static let MAX_PRESET = 10
    
    enum Action {
        /// Fetch preset list from server
        case refresh
    }
    
    enum Mutation {
        /// Set preset sections
        case setSections([PresetSectionModel]?)
        
        /// Set loading flag
        case setLoading(Bool)
    }
    
    struct State {
        /// The section list of preset list
        var sections: RevisionValue<[PresetSectionModel]>
        
        /// Is loading to process
        var isLoading: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let networkService: NetworkServiceProtocol

    private var dataSource: PresetSectionDataSource
    
    // MARK: - constructor
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        dataSource = PresetSectionDataSource()
        
        initialState = State(
            sections: RevisionValue(dataSource.makeSections()),
            isLoading: false
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return actionRefresh()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        // Request only preset never fetched
        guard dataSource.hotPresetSection == nil || dataSource.allPresetSection == nil else { return .empty() }
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let requestPresets: Observable<Mutation> = Observable.zip(
            // Request hot preset list
            dataSource.hotPresetSection != nil ? .empty() :
                networkService.requestHotPresets()
                    .do(onSuccess: { self.dataSource.setHotPresetItems($0) })
                    .catchError {
                        Logger.error($0)
                        return .just([])
                    }
                    .asObservable(),
            // Request all preset list
            dataSource.allPresetSection != nil ? .empty() :
                networkService.requestPresets()
                    .do(onSuccess: { self.dataSource.setAllPresetItems($0) })
                    .catchError {
                        // Return empty array when error occured
                        Logger.error($0)
                        return .just([])
                    }
                    .asObservable()
        )
            .map { _, _ in .setSections(self.dataSource.makeSections()) }
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestPresets, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - preste datasource
typealias PresetSectionModel = SectionModel<PresetSectionType, PresetCellType>

enum PresetSectionType {
    case hot
    case all
}

enum PresetCellType {
    case regular(TimeSetCollectionViewCellReactor)
    case all
}

struct PresetSectionDataSource {
    // MARK: - section
    private(set) var hotPresetSection: [PresetCellType]?
    private(set) var allPresetSection: [PresetCellType]?
    
    // MARK: - public method
    mutating func setHotPresetItems(_ items: [TimeSetItem]) {
        hotPresetSection = items
            .map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0)) }
    }
    
    mutating func setAllPresetItems(_ items: [TimeSetItem]) {
        allPresetSection = items
            .range(0 ..< PresetViewReactor.MAX_PRESET)
            .map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0)) }
        
        if items.count > PresetViewReactor.MAX_PRESET {
            // Add all time set cell type if item's count exceed MAX_PRESET
            allPresetSection?.append(.all)
        }
    }
    
    func makeSections() -> [PresetSectionModel] {
        // Make Sections
        let hotPresetSection: PresetSectionModel
        if let hotPresetItems = self.hotPresetSection {
            hotPresetSection = PresetSectionModel(model: .hot, items: hotPresetItems)
        } else {
            hotPresetSection = PresetSectionModel(model: .hot, items: [])
        }
        
        let allPresetSection: PresetSectionModel
        if let allPresetItems = self.allPresetSection {
            allPresetSection = PresetSectionModel(model: .all, items: allPresetItems)
        } else {
            allPresetSection = PresetSectionModel(model: .all, items: [])
        }
        
        return [hotPresetSection, allPresetSection].filter { $0.items.count > 0 }
    }
}
