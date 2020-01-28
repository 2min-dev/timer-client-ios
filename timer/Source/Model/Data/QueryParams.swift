//
//  QueryParams.swift
//  timer
//
//  Created by JSilver on 2020/01/16.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

struct PaginationParam {
    let count: Int
    let page: Int
    
    var range: Range<Int> { count * (page - 1) ..< count * page }
    
    init(count: Int, page: Int = 1) {
        self.count = max(count, 0)
        self.page = max(page, 1)
    }
}

struct SortingParam {
    let keyPath: String
    let accending: Bool
    
    init(keyPath: String, accending: Bool = false) {
        self.keyPath = keyPath
        self.accending = accending
    }
}
