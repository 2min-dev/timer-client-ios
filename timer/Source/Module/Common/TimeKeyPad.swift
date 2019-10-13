//
//  TimeKeyPad.swift
//  timer
//
//  Created by JSilver on 10/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeKeyPad: UIView {
    enum Key: Int {
        case hour = 0
        case minute
        case second
    }
    
    // MARK: - view properties
    let hourButton: UIButton = {
        let view = UIButton()
        view.tag = Key.hour.rawValue
        
        view.setTitle("productivity_button_hour_title".localized, for: .normal)
        return view
    }()
    
    let minuteButton: UIButton = {
        let view = UIButton()
        view.tag = Key.minute.rawValue
        view.setTitle("productivity_button_minute_title".localized, for: .normal)
        return view
    }()
    
    let secondButton: UIButton = {
        let view = UIButton()
        view.tag = Key.second.rawValue
        view.setTitle("productivity_button_second_title".localized, for: .normal)
        return view
    }()
    
    private lazy var timeButtonStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [hourButton, minuteButton, secondButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    // MARK: - properties
    lazy var keys = [
        hourButton,
        minuteButton,
        secondButton
    ]
    
    var font: UIFont = UIFont.systemFont(ofSize: 20) {
        didSet { keys.forEach { $0.titleLabel?.font = font } }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set constraint of subviews
        addAutolayoutSubview(timeButtonStackView)
        timeButtonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    func setTitleColor(normal: UIColor, disabled: UIColor) {
        keys.forEach {
            $0.setTitleColor(normal, for: .normal)
            $0.setTitleColor(disabled, for: .disabled)
        }
    }
}

extension Reactive where Base: TimeKeyPad {
    var enableKey: Binder<Base.Key> {
        return Binder(base.self) { _, time in
            self.base.keys.forEach { $0.isEnabled = $0.tag >= time.rawValue ? true : false }
        }
    }
    
    var tap: ControlEvent<Base.Key> {
        let source = Observable<Base.Key>.merge(base.keys.map { key in
            key.rx.tap
                .flatMap { () -> Observable<Base.Key> in
                    guard let key = Base.Key(rawValue: key.tag) else { return .empty() }
                    return .just(key)
                }
        })
        .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
        
        return ControlEvent(events: source)
    }
}
