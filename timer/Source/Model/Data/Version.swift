//
//  Version.swift
//  timer
//
//  Created by JSilver on 2019/11/22.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

struct Version: Equatable, Comparable {
    // MARK: - properties
    var major: Int
    var minor: Int
    var patch: Int
    
    // MARK: - constructor
    init(major: Int = 0, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(_ version: String) {
        guard let range = version.range(regex: "((\\d*\\.?){1,2}\\d+$|\\d*)"),
            range.location == 0 && range.length == version.count else { return nil }
        
        let versions = version.split(separator: ".")
            .compactMap { Int($0) }
            .enumerated()
            .reduce([0, 0, 0]) { result, item in
                var result = result
                result[item.offset] = item.element
                
                return result
            }
        
        self.init(major: versions[0], minor: versions[1], patch: versions[2])
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        return lhs.major < rhs.major ||
            lhs.major == rhs.major && lhs.minor < rhs.minor ||
            lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch
    }
}
