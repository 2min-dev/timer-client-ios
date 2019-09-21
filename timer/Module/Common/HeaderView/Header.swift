//
//  Header.swift
//  timer
//
//  Created by JSilver on 20/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Header: UIView {
    enum Action {
        case cancel
        case confirm
        case back
        case home
        case setting
        case history
        case search
        case bookmark
        case share
        case delete
        case additional
    }
    
    // MARK: - properties
    var action: PublishRelay<Action> = PublishRelay()
    var disposeBag: DisposeBag = DisposeBag() {
        didSet { bind() }
    }
    
    var title: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind() {
        // Write down binding of header to action stream
    }
}

extension Reactive where Base: Header {
    /// The button tap event
    var tap: ControlEvent<Base.Action> {
        return ControlEvent(events: base.action)
    }
    
    /// The title of header view
    var title: Binder<String> {
        return Binder(base) { _, title in self.base.title = title }
    }
}
