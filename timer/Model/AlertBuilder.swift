//
//  AlertBuilder.swift
//  timer
//
//  Created by JSilver on 05/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class AlertBuilder {
    private var title: String?
    private var message: String?
    private var style: UIAlertController.Style
    private var actions: [UIAlertAction] = []
    
    init(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert) {
        self.title = title
        self.message = message
        self.style = style
    }
    
    func addAction(title: String?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> AlertBuilder {
        actions.append(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func build() -> UIAlertController {
        let viewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { viewController.addAction($0) }
        return viewController
    }
}
