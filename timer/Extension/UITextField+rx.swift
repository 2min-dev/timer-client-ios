//
//  UITextField+rx.swift
//  timer
//
//  Created by JSilver on 01/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    public var textChanged: ControlEvent<String?> {
        let source: Observable<String?> = .merge(base.rx.observe(String.self, "text"),
                                                 base.rx.controlEvent(.editingChanged).withLatestFrom(base.rx.text))
        return ControlEvent(events: source)
    }
}
