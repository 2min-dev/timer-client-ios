//
//  CommonConstants.swift
//  timer
//
//  Created by Jeong Jin Eun on 24/12/2018.
//  Copyright © 2018 Jeong Jin Eun. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
    static let device = {
        return UIDevice.current.userInterfaceIdiom
    }()
    
    static let appTitle: String = "2min"
    
    // base screen display weight
    static let weight: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return UIScreen.main.bounds.width / 375.0
        case .pad:
            return UIScreen.main.bounds.width / 768.0
        default:
            // default isn't have mean yet.
            return UIScreen.main.bounds.width / 32.0
        }
    }()
    
    // second time
    enum Time {
        static let hour: Int = 3600
        static let minute: Int = 60
    }
    
    // project font define
    enum Font {
        static let Light: UIFont! = UIFont.init(name: "NanumSquareL", size: 17.0)
        static let Regular: UIFont! = UIFont.init(name: "NanumSquareR", size: 17.0)
        static let Bold: UIFont! = UIFont.init(name: "NanumSquareB", size: 17.0)
        static let ExtraBold: UIFont! = UIFont.init(name: "NanumSquareEB", size: 17.0)
    }
    
    enum Color {
        static let clear: UIColor = .clear
        
        static let codGray: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "cod_gray")!
            } else {
                return UIColor(hex: "#0A0A0A")
            }
        }()

        static let doveGray: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "dove_gray")!
            } else {
                return UIColor(hex: "#646464")
            }
        }()

        static let silver: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "silver")!
            } else {
                return UIColor(hex: "#C8C8C8")
            }
        }()

        static let gallery: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "gallery")!
            } else {
                return UIColor(hex: "#F0F0F0")
            }
        }()

        static let white: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "white")!
            } else {
                return UIColor(hex: "#FFFFFF")
            }
        }()

        static let carnation: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "carnation")!
            } else {
                return UIColor(hex: "#F24150")
            }
        }()

        static let navyBlue: UIColor = {
            if #available(iOS 11.0, *) {
                return UIColor(named: "navy_blue")!
            } else {
                return UIColor(hex: "#020873")
            }
        }()
    }
    
    enum Locale {
        static let Korea: String = "ko_KR"
        static let USA: String = "en_US"
    }
}
