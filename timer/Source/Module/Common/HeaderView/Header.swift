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
        case close
    }
    
    // MARK: - view properties
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    // MARK: - properties
    var title: String? {
        set { titleLabel.text = newValue }
        get { titleLabel.text }
    }
    
    var action: PublishRelay<Action> = PublishRelay()
    var disposeBag: DisposeBag = DisposeBag() {
        didSet { bind() }
    }
    
    // MARK: - constructor
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
        let source = base.action
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
        
        return ControlEvent(events: source)
            
    }
    
    /// The title of header view
    var title: Binder<String> {
        return Binder(base) { header, title in header.title = title }
    }
}
