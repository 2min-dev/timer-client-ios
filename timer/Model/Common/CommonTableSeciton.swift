//
//  CommonTableSection.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxDataSources

struct CommonTableSection {
    let title: String
    var items: [CommonTableItem]
}

extension CommonTableSection: SectionModelType {
    init(original: CommonTableSection, items: [CommonTableItem]) {
        self = original
        self.items = items
    }
}
