//
//  UIViewController+child.swift
//  timer
//
//  Created by Jeong Jin Eun on 26/03/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension UIViewController {
    func addChild(_ viewController: UIViewController, in view: UIView) {
        addChild(viewController)
        
        viewController.view.frame = view.frame
        view.addSubview(viewController.view)
        
        viewController.view.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        viewController.didMove(toParent: self)
    }
}
