//
//  UIView+rx.swift
//  timer
//
//  Created by JSilver on 2019/11/20.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIView {
    func setHidden(_ isHidden: Bool, animated: Bool = false) {
        if animated {
            self.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = isHidden ? 0 : 1
            }, completion: { _ in
                self.isHidden = isHidden
            })
        } else {
            self.isHidden = isHidden
            alpha = isHidden ? 0 : 1
        }
    }
}

extension Reactive where Base: UIView {
    var isHiddenWithAnimation: Binder<Bool> {
        return Binder(base) { view, isHidden in
            view.setHidden(isHidden, animated: true)
        }
    }
}
