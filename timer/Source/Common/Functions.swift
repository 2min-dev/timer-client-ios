//
//  CommonFunctions.swift
//  timer
//
//  Created by Jeong Jin Eun on 27/01/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//
import UIKit

func getCurrentDateString(format: String) -> String {
    return getDateString(format: format, date: Date())
}

func getDateString(format: String, date: Date, locale: Locale = Locale(identifier: Constants.Locale.Korea)) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.locale = locale
    formatter.dateFormat = format
    return formatter.string(from: date)
}

func getDate(format: String, date: String) -> Date? {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.date(from: date)
}

func getTime(interval: TimeInterval) -> (Int, Int, Int) {
    let time = Int(interval)
    
    let seconds = time % 60
    let minutes = (time / 60) % 60
    let hours = time / 3600
    
    return (hours, minutes, seconds)
}

func openAppStore(completionHandler: ((Bool) -> Void)? = nil) {
    if let url = URL(string: "itms-apps://itunes.apple.com/app/id1483376212"),
        UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
    }
}
