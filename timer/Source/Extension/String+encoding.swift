//
//  String+encoding.swift
//  timer
//
//  Created by JSilver on 2019/11/21.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

extension String.Encoding {
    public static let euc_kr: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0940))
}
