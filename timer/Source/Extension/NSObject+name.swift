//
//  NSObject+name.swift
//  timer
//
//  Created by JSilver on 02/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

extension NSObject {
    static var name: String {
        return String(describing: self)
    }
}
