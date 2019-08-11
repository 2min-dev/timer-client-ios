//
//  JSONCodec.swift
//  timer
//
//  Created by JSilver on 11/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

class JSONCodec {
    /// Encode encoable object to JSON string
    /// - parameters:
    ///   - value: The instance adopted `Encodable`
    ///   - encoding: The type of string encode
    /// - returns: Encoded object string. If encode fail, return `nil`
    static func encode<T>(_ value: T, encoding: String.Encoding = .utf8) -> String? where T: Encodable {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value),
            let string = String(data: data, encoding: encoding) else { return nil }
     
        // Print log
        print(value: value, encoding: encoding)
        return string
    }
    
    /// Decode JSON string to decoable object
    /// - parameters:
    ///   - string: The JSON string
    ///   - type: Type of object to decode
    ///   - encoding: The type of string encode
    /// - returns: Decoded object. If decode fail, return `nil`
    static func decode<T>(_ string: String, type: T.Type, encoding: String.Encoding = .utf8) -> T? where T: Codable {
        let decoder = JSONDecoder()
        
        guard let data = string.data(using: encoding),
            let value = try? decoder.decode(type, from: data) else {
            return nil
        }
        
        // Print log
        print(value: value, encoding: encoding)
        return value
    }
    
    /// Print json string log
    static func print<T>(value: T, encoding: String.Encoding) where T: Encodable {
       let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
       guard let data = try? encoder.encode(value),
        let string = String(data: data, encoding: encoding) else { return }
    
        var log = "[JSON ENCODED OBJECT]\n"
        log.append("\(type(of: value)) = \(string)")
        
        Logger.info(log)
    }
}
