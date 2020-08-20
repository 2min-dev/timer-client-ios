//
//  TimerBadgeSection.swift
//  timer
//
//  Created by JSilver on 02/10/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxDataSources

typealias TimerBadgeSectionModel = AnimatableSectionModel<TimerBadgeSectionType, TimerBadgeCellType>

/// Timer badge section type
enum TimerBadgeSectionType: Int, IdentifiableType {
    case leftExtra = 0
    case regular
    case rightExtra
    
    var identity: Self { return self }
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
            return type.identity
        }
    }
    
    static func == (lhs: TimerBadgeCellType, rhs: TimerBadgeCellType) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum TimerBadgeExtraCellType: IdentifiableType {
    case add
    case `repeat`(TimerBadgeRepeatCellReactor)
    
    var identity: String {
        switch self {
        case .add:
            return "add"
            
        case .repeat(_):
            return "repeat"
        }
    }
}

struct TimerBadgeSectionDataSource {
    // MARK: - section
    private(set) var regularSection: [TimerBadgeCellType] = []
    private(set) var leftExtraSection: [TimerBadgeCellType] = []
    private(set) var rightExtraSection: [TimerBadgeCellType] = []
    
    private var identity: Int = 0
    
    // MARK: - constructor
    init(regulars: [TimerItem], leftExtras: [TimerBadgeExtraCellType] = [], rightExtras: [TimerBadgeExtraCellType] = [], index: Int? = nil) {
        regularSection = regulars.enumerated()
            .map {
                let cell: TimerBadgeCellType = .regular(
                    TimerBadgeCellReactor(
                        id: identity,
                        time: $1.target,
                        index: $0,
                        count: regulars.count,
                        isSelected: $0 == index
                    )
                )
                identity += 1
                return cell
        }
        
        leftExtraSection = leftExtras.map { .extra($0) }
        rightExtraSection = rightExtras.map { .extra($0) }
    }
    
    // MARK: - private method
    private func refresh() {
        regularSection.enumerated().forEach {
            guard case let .regular(reactor) = $1 else { return }
            reactor.action.onNext(.updateIndex($0))
            reactor.action.onNext(.updateCount(regularSection.count))
        }
    }
    
    // MARK: - public method
    /// Set new time set item to cell reactor
    func setTimeSet(item: TimeSetItem) {
        leftExtraSection.forEach {
            if case let .extra(.repeat(reactor)) = $0 {
                reactor.action.onNext(.timeSetChanged(item))
            }
        }
        
        rightExtraSection.forEach {
            if case let .extra(.repeat(reactor)) = $0 {
                reactor.action.onNext(.timeSetChanged(item))
            }
        }
    }
    
    /// Update present time state of cell at index
    func setTime(_ time: TimeInterval, at index: Int) {
        guard (0 ..< regularSection.count).contains(index),
            case let .regular(reactor) = regularSection[index] else { return }
        
        reactor.action.onNext(.updateTime(time))
    }
    
    /// Update selected state of cell at index
    func setSelected(_ isSelected: Bool, at index: Int) {
        guard (0 ..< regularSection.count).contains(index),
            case let .regular(reactor) = regularSection[index] else { return }
        
        reactor.action.onNext(.select(isSelected))
    }
    
    /// Append new timer item
    mutating func append(item: TimerItem) {
        regularSection.append(.regular(TimerBadgeCellReactor(id: identity, time: item.end)))
        identity += 1
        
        refresh()
    }
    
    /// Remove timer item at index
    mutating func remove(at index: Int) {
        regularSection.remove(at: index)
        refresh()
    }
    
    /// Swap timer item at source index to destination index
    mutating func swap(at sourceIndex: Int, to destinationIndex: Int) {
        regularSection.swapAt(sourceIndex, destinationIndex)
        if case let .regular(sourceReactor) = regularSection[destinationIndex],
            case let .regular(destinationReactor) = regularSection[sourceIndex] {
            sourceReactor.action.onNext(.updateIndex(destinationIndex))
            destinationReactor.action.onNext(.updateIndex(sourceIndex))
        }
    }
    
    /// Clear timer items
    mutating func clear() {
        // Remove all timer items except first item to maintain first identity
        // If you clear all item, animate disappear all items and appear first item.
        guard let item = regularSection.first, case let .regular(reactor) = item else { return }
        reactor.action.onNext(.updateTime(0))
        
        regularSection = [item]
        refresh()
    }
    
    func makeSections(isExtrasIncluded: ([TimerBadgeCellType], TimerBadgeExtraCellType) -> Bool = { _, _ in true }) -> [TimerBadgeSectionModel] {
        let regularSection = TimerBadgeSectionModel(model: .regular, items: self.regularSection)
        
        let leftExtraSection = TimerBadgeSectionModel(
            model: .leftExtra,
            items: self.leftExtraSection.filter {
                guard case let .extra(type) = $0 else { return false }
                return isExtrasIncluded(self.regularSection, type)
        })
        
        let rightExtraSection = TimerBadgeSectionModel(
            model: .rightExtra,
            items: self.rightExtraSection.filter {
                guard case let .extra(type) = $0 else { return false }
                return isExtrasIncluded(self.regularSection, type)
        })
        
        return [leftExtraSection, regularSection, rightExtraSection]
    }
}
