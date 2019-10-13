//
//  Primitive+adjust.swift
//  timer
//
//  Created by Jeong Jin Eun on 28/02/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension Int {
    func adjust() -> CGFloat {
        return CGFloat(self) * Constants.weight
    }
}

extension Float {
    func adjust() -> CGFloat {
        return CGFloat(self) * Constants.weight
    }
}

extension Double {
    func adjust() -> CGFloat {
        return CGFloat(self) * Constants.weight
    }
}
