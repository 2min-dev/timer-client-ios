//
//  List+array.swift
//  timer
//
//  Created by JSilver on 05/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RealmSwift

extension Array where Element: Object {
    func toList() -> List<Element> {
        let list = List<Element>()
        list.append(objectsIn: self)
        return list
    }
}

extension List {
    func toArray() -> [Element] {
        return Array(self)
    }
}

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}

extension LazyFilterSequence {
    func toArray() -> [Element] {
        return Array(self)
    }
}
