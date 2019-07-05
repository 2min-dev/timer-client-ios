//
//  NSString+regex.swift
//  timer
//
//  Created by Jeong Jin Eun on 12/03/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension String {
    func range(regex: String) -> NSRange? {
        let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let range = regex?.matches(in: self, range: NSRange(location: 0, length: self.count))
        
        return range?.first?.range
    }
}
