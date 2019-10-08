//
//  UIViewController+child.swift
//  timer
//
//  Created by Jeong Jin Eun on 26/03/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        }
        
        if presentingViewController != nil {
            return true
        }
        
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    func dismissOrPopViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if isModal {
            dismiss(animated: animated, completion: completion)
        } else {
            navigationController?.popViewController(animated: animated)
        }
    }
    
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
