//
//  keyPad.swift
//  timer
//
//  Created by JSilver on 05/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KeyPad: UIView {
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
    }
    
    // MARK: - view properties
    let oneButton: UIButton = {
        let view = UIButton()
        view.tag = Key.one.rawValue
        view.setAttributedTitle(NSAttributedString(string: "1", attributes: nil), for: .normal)
        return view
    }()
    
    let twoButton: UIButton = {
        let view = UIButton()
        view.tag = Key.two.rawValue
        view.setAttributedTitle(NSAttributedString(string: "2", attributes: nil), for: .normal)
        return view
    }()
    
    let threeButton: UIButton = {
        let view = UIButton()
        view.tag = Key.three.rawValue
        view.setAttributedTitle(NSAttributedString(string: "3", attributes: nil), for: .normal)
        return view
    }()
    
    let fourButton: UIButton = {
        let view = UIButton()
        view.tag = Key.four.rawValue
        view.setAttributedTitle(NSAttributedString(string: "4", attributes: nil), for: .normal)
        return view
    }()
    
    let fiveButton: UIButton = {
        let view = UIButton()
        view.tag = Key.five.rawValue
        view.setAttributedTitle(NSAttributedString(string: "5", attributes: nil), for: .normal)
        return view
    }()
    
    let sixButton: UIButton = {
        let view = UIButton()
        view.tag = Key.six.rawValue
        view.setAttributedTitle(NSAttributedString(string: "6", attributes: nil), for: .normal)
        return view
    }()
    
    let sevenButton: UIButton = {
        let view = UIButton()
        view.tag = Key.seven.rawValue
        view.setAttributedTitle(NSAttributedString(string: "7", attributes: nil), for: .normal)
        return view
    }()
    
    let eightButton: UIButton = {
        let view = UIButton()
        view.tag = Key.eight.rawValue
        view.setAttributedTitle(NSAttributedString(string: "8", attributes: nil), for: .normal)
        return view
    }()
    
    let nineButton: UIButton = {
        let view = UIButton()
        view.tag = Key.nine.rawValue
        view.setAttributedTitle(NSAttributedString(string: "9", attributes: nil), for: .normal)
        return view
    }()
    
    let zeroButton: UIButton = {
        let view = UIButton()
        view.tag = Key.zero.rawValue
        view.setAttributedTitle(NSAttributedString(string: "0", attributes: nil), for: .normal)
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.tag = Key.cancel.rawValue
        view.setAttributedTitle(NSAttributedString(string: "X", attributes: nil), for: .normal)
        return view
    }()
    
    let backButton: UIButton = {
        let view = UIButton()
        view.tag = Key.back.rawValue
        view.setAttributedTitle(NSAttributedString(string: "<", attributes: nil), for: .normal)
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
        let view = UIStackView(arrangedSubviews: [self.cancelButton, self.zeroButton, self.backButton])
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
    fileprivate lazy var keyPads: [UIButton] = [
        self.oneButton,
        self.twoButton,
        self.threeButton,
        self.fourButton,
        self.fiveButton,
        self.sixButton,
        self.sevenButton,
        self.eightButton,
        self.nineButton,
        self.zeroButton,
        self.cancelButton,
        self.backButton
    ]
    
    private var normalAttributes: [NSAttributedString.Key: Any] = [:] {
        didSet {
            keyPads.forEach {
                guard let string = $0.attributedTitle(for: .normal)?.string else { return }
                $0.setAttributedTitle(NSAttributedString(string: string, attributes: normalAttributes), for: .normal)
            }
        }
    }
    
    private var highlightAttributes: [NSAttributedString.Key: Any] = [:] {
        didSet {
            keyPads.forEach {
                guard let string = $0.attributedTitle(for: .normal)?.string else { return }
                $0.setAttributedTitle(NSAttributedString(string: string, attributes: highlightAttributes), for: .highlighted)
            }
        }
    }
    
    var foregroundColor: UIColor = .black {
        didSet {
            normalAttributes[.foregroundColor] = foregroundColor
        }
    }
    
    var highlightColor: UIColor = .gray {
        didSet {
            highlightAttributes[.foregroundColor] = highlightColor
        }
    }
    
    var fontSize: CGFloat = 17 {
        didSet {
            normalAttributes[.font] = font.withSize(fontSize)
            highlightAttributes[.font] = font.withSize(fontSize)
        }
    }
    
    var font: UIFont = Constants.Font.NanumSquareRoundEB {
        didSet {
            normalAttributes[.font] = font.withSize(fontSize)
            highlightAttributes[.font] = font.withSize(fontSize)
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperty()
        
        setSubviewForAutoLayout(keyPadStackView)
        
        keyPadStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private method
    /// Initialize view properties
    private func initProperty() {
        normalAttributes = [
            .foregroundColor: foregroundColor,
            .font: font.withSize(fontSize)
        ]
        
        highlightAttributes = normalAttributes
        highlightAttributes[.foregroundColor] = highlightColor
        
        keyPads.forEach {
            guard let string = $0.attributedTitle(for: .normal)?.string else { return }
            
            $0.setAttributedTitle(NSAttributedString(string: string, attributes: normalAttributes), for: .normal)
            $0.setAttributedTitle(NSAttributedString(string: string, attributes: highlightAttributes), for: .highlighted)
        }
    }
}

// MARK: - Extension
extension Reactive where Base: KeyPad {
    var keyPadTap: ControlEvent<Base.Key> {
        let source = Observable.merge(base.keyPads.map { keyPad in
            keyPad.rx.tap
                .flatMap { () -> Observable<Base.Key> in
                    guard let key = Base.Key(rawValue: keyPad.tag) else { return Observable.empty() }
                    return Observable.just(key)
                }
        })
        
        return ControlEvent(events: source)
    }
}
