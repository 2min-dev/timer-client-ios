//
//  TimerBadgeSection.swift
//  timer
//
//  Created by JSilver on 02/10/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxDataSources

typealias TimerBadgeSectionModel = AnimatableSectionModel<TimerBadgeSectionType, TimerBadgeCellType>

/// Timer badge section type
enum TimerBadgeSectionType: Int, IdentifiableType {
    case leftExtra = 0
    case regular
    case rightExtra
    
    var identity: Self { return self }
}

enum TimerBadgeExtraType {
    case add
    case `repeat`
}

/// Timer badge cell type
enum TimerBadgeCellType: IdentifiableType, Equatable {
    case regular(TimerBadgeCellReactor)
    case extra(TimerBadgeExtraCellType)
    
    var identity: String {
        switch self {
        case let .regular(reactor):
            return String(reactor.id)
            
        case let .extra(type):
            return type.id
        }
    }
    
    static func == (lhs: TimerBadgeCellType, rhs: TimerBadgeCellType) -> Bool {
        return lhs.identity == rhs.identity
    }
}

/// Timer badge extra cell type
enum TimerBadgeExtraCellType {
    case add
    case `repeat`(TimerBadgeRepeatCellReactor)
    // Define here, if need to add any extra cell type
    
    var id: String {
        switch self {
        case .add:
            return "add"
            
        case .repeat(_):
            return "repeat"
        }
    }
}

class TimerBadgeDataSource {
    private(set) var regulars: [TimerBadgeCellReactor]
    let extras: [TimerBadgeExtraType: TimerBadgeExtraCellType]
    
    private let leftExtras: [TimerBadgeExtraType]
    private let rightExtras: [TimerBadgeExtraType]
    
    private var identity: Int = 0
    
    init(timers: [TimerItem] = [],
         extras: [TimerBadgeExtraType: TimerBadgeExtraCellType] = [:],
         leftExtras: [TimerBadgeExtraType] = [],
         rightExtras: [TimerBadgeExtraType] = [],
         index: Int? = nil) {
        identity = timers.count
        regulars = timers.enumerated().map { offset, timer in
            TimerBadgeCellReactor(id: offset, time: timer.end, index: offset, count: timers.count, isSelected: offset == index)
        }
        self.extras = extras
        self.leftExtras = leftExtras
        self.rightExtras = rightExtras
    }
    
    /// Append new timer item
    func append(item: TimerItem) {
        regulars.append(TimerBadgeCellReactor(id: identity, time: item.end))
        identity += 1
    }
    
    /// Remove timer item at index
    func remove(at index: Int) {
        regulars.remove(at: index)
    }
    
    /// Swap timer item at source index to destination index
    func swap(at sourceIndex: Int, to destinationIndex: Int) {
        regulars.swapAt(sourceIndex, destinationIndex)
    }
    
    /// Clear timer items
    func clear() {
        // Remove all timer items except first item to maintain first identity
        guard let item = regulars.first else { return }
        item.action.onNext(.updateTime(0))
        regulars = [item]
    }
    
    func makeSections(isExtrasIncluded: ([TimerBadgeCellReactor], TimerBadgeExtraType) -> Bool = { _, _ in true }) -> [TimerBadgeSectionModel] {
        // Make regular section
        let regularItems = regulars.enumerated()
            .map { (offset, reactor) -> TimerBadgeCellType in
                reactor.action.onNext(.updateIndex(offset))
                reactor.action.onNext(.updateCount(regulars.count))
                
                return .regular(reactor)
            }
        
        // Make left extra item section
        let leftItems: [TimerBadgeCellType] = leftExtras
            .filter { isExtrasIncluded(regulars, $0) }
            .compactMap { extras[$0] }
            .map { .extra($0) }
        
        // Make right extra item section
        let rightItems: [TimerBadgeCellType] = rightExtras
            .filter { isExtrasIncluded(regulars, $0) }
            .compactMap { extras[$0] }
            .map { .extra($0) }
        
        return [
            TimerBadgeSectionModel(model: .leftExtra, items: leftItems),
            TimerBadgeSectionModel(model: .regular, items: regularItems),
            TimerBadgeSectionModel(model: .rightExtra, items: rightItems)
        ]
    }
}
