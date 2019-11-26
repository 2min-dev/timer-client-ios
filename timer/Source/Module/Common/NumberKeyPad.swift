//
//  NumberKeyPad.swift
//  timer
//
//  Created by JSilver on 05/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NumberKeyPad: UIView {
    enum Key: Int {
        case zero = 0
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case cancel
        case back
        
        static func == (value: Int, origin: Key) -> Bool {
            return value == origin.rawValue
        }
        
        static func != (value: Int, origin: Key) -> Bool {
            return value != origin.rawValue
        }
    }
    
    // MARK: - view properties
    let oneButton: UIButton = {
        let view = UIButton()
        view.tag = Key.one.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("1", for: .normal)
        return view
    }()
    
    let twoButton: UIButton = {
        let view = UIButton()
        view.tag = Key.two.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("2", for: .normal)
        return view
    }()
    
    let threeButton: UIButton = {
        let view = UIButton()
        view.tag = Key.three.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("3", for: .normal)
        return view
    }()
    
    let fourButton: UIButton = {
        let view = UIButton()
        view.tag = Key.four.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("4", for: .normal)
        return view
    }()
    
    let fiveButton: UIButton = {
        let view = UIButton()
        view.tag = Key.five.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("5", for: .normal)
        return view
    }()
    
    let sixButton: UIButton = {
        let view = UIButton()
        view.tag = Key.six.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("6", for: .normal)
        return view
    }()
    
    let sevenButton: UIButton = {
        let view = UIButton()
        view.tag = Key.seven.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("7", for: .normal)
        return view
    }()
    
    let eightButton: UIButton = {
        let view = UIButton()
        view.tag = Key.eight.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("8", for: .normal)
        return view
    }()
    
    let nineButton: UIButton = {
        let view = UIButton()
        view.tag = Key.nine.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("9", for: .normal)
        return view
    }()
    
    let zeroButton: UIButton = {
        let view = UIButton()
        view.tag = Key.zero.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("0", for: .normal)
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.tag = Key.cancel.rawValue
        view.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        view.setTitle("keypad_cancel".localized, for: .normal)
        return view
    }()
    
    private lazy var cancelWrapView: UIView = { [unowned self] in
        let view = UIView()
        // Set constraint of subviews
        view.addAutolayoutSubview(self.cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    let backButton: UIButton = {
        let view = UIButton()
        view.tag = Key.back.rawValue
        view.setImage(UIImage(named: "icon_keypad_delete")?.withRenderingMode(.alwaysTemplate), for: .normal)
        return view
    }()
    
    private lazy var baackWrapView: UIView = { [unowned self] in
        let view = UIView()
        // Set constraint of subviews
        view.addAutolayoutSubview(self.backButton)
        backButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var keyPadOneStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.oneButton, self.twoButton, self.threeButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var keyPadTwoStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.fourButton, self.fiveButton, self.sixButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var keyPadThreeStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.sevenButton, self.eightButton, self.nineButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var keyPadFourStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.cancelWrapView, self.zeroButton, self.baackWrapView])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var keyPadStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.keyPadOneStackView, self.keyPadTwoStackView, self.keyPadThreeStackView, self.keyPadFourStackView])
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    // MARK: - properties
    lazy var keys: [UIButton] = [
        oneButton,
        twoButton,
        threeButton,
        fourButton,
        fiveButton,
        sixButton,
        sevenButton,
        eightButton,
        nineButton,
        zeroButton,
        cancelButton,
        backButton
    ]
    
    var foregroundColor: UIColor = UIColor(hex: "#007AFF") {
        didSet {
            keys.forEach {
                $0.setTitleColor(foregroundColor, for: .normal)
                $0.tintColor = foregroundColor
            }
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            keys.forEach { $0.titleLabel?.font = font }
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAutolayoutSubview(keyPadStackView)
        keyPadStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extension
extension Reactive where Base: NumberKeyPad {
    var keyPadTap: ControlEvent<Base.Key> {
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
