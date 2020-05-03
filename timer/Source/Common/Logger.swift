//
//  Logger.swift
//  timer
//
//  Created by Jeong Jin Eun on 02/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class Logger {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func log(_ message: String) {
        print("\(dateFormatter.string(from: Date())) \(message)")
    }
    
    static func verbose(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        log("💜 \(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func debug(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        log("💚 \(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func info(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        log("💙 \(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func warning(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        log("💛 \(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func error(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        log("❤️ \(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    enum Event: String {
        case click = "click"
    }
    
    enum Parameter {
        enum Key: String {
            case componentName = "component_name"
            case text = "text"
        }
    }
    
    func logEvent(_ event: Event, parameters: [Parameter.Key: Any]? = nil) {
        // Transform param
        var param: [String: Any]? = parameters != nil ? [:] : nil
        parameters?.forEach { param?[$0.rawValue] = $1 }
        
        // Firebase analytics log event
        Analytics.logEvent(event.rawValue, parameters: param)
    }
}
