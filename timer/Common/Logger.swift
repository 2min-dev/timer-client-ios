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
    
    static func verbose(_ message: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.verbose("\(className).\(function):\(line) \(message)")
        #endif
    }
    
    static func debug(_ message: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.debug("\(className).\(function):\(line) \(message)")
        #endif
    }
    
    static func info(_ message: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.info("\(className).\(function):\(line) \(message)")
        #endif
    }
    
    static func warning(_ message: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.warning("\(className).\(function):\(line) \(message)")
        #endif
    }
    
    static func error(_ message: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent.components(separatedBy: ".").first!
        SwiftyBeaver.error("\(className).\(function):\(line) \(message)")
        #endif
    }
}
