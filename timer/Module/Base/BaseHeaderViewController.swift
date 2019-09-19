//
//  BaseHeaderViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

protocol HeaderViewController where Self: UIViewController {
    associatedtype Header: UIView
    var headerView: Header { get }
}

/// - warning: Shouldn't use `Base` controller not inherited
class BaseHeaderViewController: BaseViewController, HeaderViewController {
    var headerView: UIView { return UIView() }
}

extension BaseHeaderViewController: UIScrollViewDelegate {
    // Implement header view to have shadow by scroll offset
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetThreshold: CGFloat = 3
        let blurThreshold: CGFloat = 10
        let weight: CGFloat = 5
        
        // Set shadow by scroll
        headerView.layer.shadow(alpha: 0.04,
                                offset: CGSize(width: 0, height: min(scrollView.contentOffset.y / weight, offsetThreshold)),
                                blur: min(scrollView.contentOffset.y / weight, blurThreshold))
    }
}
