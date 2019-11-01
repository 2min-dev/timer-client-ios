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
    static func encode<T: Encodable>(_ value: T, encoding: String.Encoding) -> String? {
        guard let data = encode(value), let string = String(data: data, encoding: encoding) else { return nil }
        return string
    }
    
    /// Encode encoable object to JSON data
    /// - parameters:
    ///   - value: The instance adopted `Encodable`
    /// - returns: Encoded object data. If encode fail, return `nil`
    static func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(value)

            // Print log
            print(value: value)
            return data
        } catch {
            Logger.error(error, tag: "JSONCODEC")
            return nil
        }
    }
    
    /// Decode JSON string to decoable object
    /// - parameters:
    ///   - string: The JSON string
    ///   - type: Type of object to decode
    ///   - encoding: The type of string encode
    /// - returns: Decoded object. If decode fail, return `nil`
    static func decode<T: Codable>(_ string: String, type: T.Type, encoding: String.Encoding = .utf8) -> T? {
        guard let data = string.data(using: encoding) else { return nil }
        return decode(data, type: type)
    }
    
    /// Decode JSON string to decoable object
    /// - parameters:
    ///   - data: The JSON data
    ///   - type: Type of object to decode
    /// - returns: Decoded object. If decode fail, return `nil`
    static func decode<T: Codable>(_ data: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let value = try decoder.decode(type, from: data)
            
            // Print log
            print(value: value)
            return value
        } catch {
            Logger.error(error, tag: "JSONCODEC")
            return nil
        }
    }
    
    /// Print json string log
    static func print<T: Encodable>(value: T) {
        #if DEBUG
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(value),
            let string = String(data: data, encoding: .utf8) else { return }
        
        var log = "[JSON ENCODED OBJECT]\n"
        log.append("\(type(of: value)) = \(string)")
        
        Logger.info(log)
        #endif
    }
}
