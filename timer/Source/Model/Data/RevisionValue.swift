//
//  RevisionValue.swift
//  timer
//
//  Created by JSilver on 2019/12/01.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

struct RevisionValue<T>: Equatable {
    private let revision: UInt
    var value: T
    
    private init(revision: UInt, value: T) {
        self.revision = revision
        self.value = value
    }
    
    init(_ value: T) {
        revision = 0
        self.value = value
    }
    
    func next(_ value: T? = nil) -> RevisionValue {
        guard let value = value else {
            return RevisionValue(revision: revision + 1, value: self.value)
        }
        
        return RevisionValue(revision: revision + 1, value: value)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.revision == rhs.revision
    }
}
