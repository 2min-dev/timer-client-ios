//
//  BaseMenuSectionItem.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxDataSources

struct BaseTableSection {
    let title: String
    var items: [BaseTableItem]
}

extension BaseTableSection: SectionModelType {
    init(original: BaseTableSection, items: [BaseTableItem]) {
        self = original
        self.items = items
    }
}
