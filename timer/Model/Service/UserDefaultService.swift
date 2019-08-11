//
//  UserDefaultService.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

protocol UserDefaultServiceProtocol {
    func set(_ value: Any, key: UserDefaultService.Key)
    func integer(_ key: UserDefaultService.Key) -> Int
    func double(_ key: UserDefaultService.Key) -> Double
    func float(_ key: UserDefaultService.Key) -> Float
    func string(_ key: UserDefaultService.Key) -> String?
}

class UserDefaultService: UserDefaultServiceProtocol {
    enum Key: String {
        case timeSetId
        
        var type: Any.Type {
            switch self {
            case .timeSetId:
                return Int.self
            }
        }
    }
    
    private let userDefault = UserDefaults.standard
    
    func set(_ value: Any, key: Key) {
        guard type(of: value) == key.type else { fatalError("You try to enter set value that doesn't match the type corresponding to the key value.") }
        userDefault.set(value, forKey: key.rawValue)
    }
    
    /// - returns: The integer value associated with the specified key. If the key doesn‘t exist, this method returns 0
    func integer(_ key: Key) -> Int {
        guard key.type is Int.Type else { fatalError("You try to get value that doesn't match the type corresponding to the key value.") }
        return userDefault.integer(forKey: key.rawValue)
    }
    
    /// - returns: The double value associated with the specified key. If the key doesn‘t exist, this method returns 0
    func double(_ key: Key) -> Double {
        guard key.type is Double.Type else { fatalError("You try to get value that doesn't match the type corresponding to the key value.") }
        return userDefault.double(forKey: key.rawValue)
    }
    
    /// - returns: The float value associated with the specified key. If the key doesn‘t exist, this method returns 0
    func float(_ key: Key) -> Float {
        guard key.type is Float.Type else { fatalError("You try to get value that doesn't match the type corresponding to the key value.") }
        return userDefault.float(forKey: key.rawValue)
    }
    
    /// - returns: The string value associated with the specified key. If the key doesn‘t exist, this method returns nil
    func string(_ key: Key) -> String? {
        guard key.type is String.Type else { fatalError("You try to get value that doesn't match the type corresponding to the key value.") }
        return userDefault.string(forKey: key.rawValue)
    }
}
