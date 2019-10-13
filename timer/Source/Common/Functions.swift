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

func roundCorners(view: UIView, byRoundingCorners: UIRectCorner, cornerRadius: CGFloat) {
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
    view.layer.mask = maskLayer
}
