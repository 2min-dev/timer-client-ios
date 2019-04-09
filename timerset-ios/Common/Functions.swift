//
//  CommonFunctions.swift
//  TaskManager-Swift
//
//  Created by Jeong Jin Eun on 27/01/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//
import UIKit

func getCurrentDateString(format: String) -> String {
    return getDateString(format: format, date: Date())
}

func getDateString(format: String, date: Date) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

func getDate(format: String, date: String) -> Date? {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.date(from: date)
}

func roundCorners(view: UIView, cornerRadius: CGFloat) {
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
    view.layer.mask = maskLayer
}
