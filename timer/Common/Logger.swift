//
//  Logger.swift
//  timer
//
//  Created by Jeong Jin Eun on 02/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import SwiftyBeaver

class Logger {
    static func initialize() {
        let console = ConsoleDestination()
        console.format = "$DYYYY-MM-dd HH:mm:ss$d $C$L$c $M"
        SwiftyBeaver.addDestination(console)
    }
    
    static func verbose(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        SwiftyBeaver.verbose("\(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func debug(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        SwiftyBeaver.debug("\(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func info(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        SwiftyBeaver.info("\(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func warning(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        let tag = tag.isEmpty ? tag : "[\(tag)] "
        SwiftyBeaver.warning("\(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
    
    static func error(_ message: Any = "", tag: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.error("\(className).\(function):\(line) \(tag)\(message)")
        #endif
    }
}
