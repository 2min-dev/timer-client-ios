//
//  NSAttributedString+string.swift
//  timer
//
//  Created by JSilver on 2020/01/27.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func setString(_ string: String) -> NSAttributedString {
        guard let attributedString = mutableCopy() as? NSMutableAttributedString else { return self }
        attributedString.mutableString.setString(string)
        
        return attributedString
    }
}
