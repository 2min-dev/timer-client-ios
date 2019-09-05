//
//  Error.swift
//  timer
//
//  Created by JSilver on 03/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum DatabaseError: Error {
    case initialize
    case transaction
    case notFound
    case unknown
}

enum TimeSetError: Error {
    case notFound
    case unknown
}
