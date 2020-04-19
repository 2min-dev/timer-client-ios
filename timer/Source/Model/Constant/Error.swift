//
//  Error.swift
//  timer
//
//  Created by JSilver on 03/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

enum DatabaseError: Error {
    case invalidFormat
    case initialize
    case transaction
    case notFound
    case wrongData
    case unknown
}

enum NetworkError: Error {
    case badRequest
    case emptyData
    case missingRequiredPrameters
    case parseError
    case unknown
}

enum TimeSetError: Error {
    case notFound
    case unknown
}
