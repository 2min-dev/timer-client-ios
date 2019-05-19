//
//  CommonConstants.swift
//  TaskManager-Swift
//
//  Created by Jeong Jin Eun on 24/12/2018.
//  Copyright © 2018 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let appTitle: String = "timerset-ios"
    
    // base screen display weight
    static let weight: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return UIScreen.main.bounds.width / 414.0
        case .pad:
            return UIScreen.main.bounds.width / 768.0
        default:
            // default isn't have mean yet.
            return UIScreen.main.bounds.width / 32.0
        }
    }()
    
    // second time
    struct Time {
        static let hour: Int = 3600
        static let minute: Int = 60
    }
    
    // project font define
    struct Font {
        static let NanumSquareRoundL: UIFont! = UIFont.init(name: "NanumSquareRoundL", size: 17.0)
        static let NanumSquareRoundR: UIFont! = UIFont.init(name: "NanumSquareRoundR", size: 17.0)
        static let NanumSquareRoundB: UIFont! = UIFont.init(name: "NanumSquareRoundB", size: 17.0)
        static let NanumSquareRoundEB: UIFont! = UIFont.init(name: "NanumSquareRoundEB", size: 17.0)
    }
    
    struct Color {
        static let appColor: UIColor = #colorLiteral(red: 0.5333333333, green: 0.8666666667, blue: 0.5333333333, alpha: 1)
        
        static let clear: UIColor = .clear
        static let white: UIColor = .white
        static let black: UIColor = .black
        static let gray: UIColor = .gray
        static let lightGray: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}
