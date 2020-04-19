//
//  CommonHeader.swift
//  timer
//
//  Created by JSilver on 19/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommonHeader: Header {
    enum ButtonType: Int {
        case back = 0
        case home
        case setting
        case history
        case search
        case share
        case delete
        case close
        
        var button: UIButton {
            let button = UIButton()
            button.tag = rawValue
            
            switch self {
            case .back:
                button.setImage(UIImage(named: "btn_back"), for: .normal)
                
            case .home:
                button.setImage(UIImage(named: "btn_home"), for: .normal)
                
            case .setting:
                button.setImage(UIImage(named: "btn_setting"), for: .normal)
                
            case .history:
                button.setImage(UIImage(named: "btn_history"), for: .normal)
                
            case .search:
                button.setImage(UIImage(named: "btn_search"), for: .normal)
                
            case .share:
                button.setImage(UIImage(named: "btn_share"), for: .normal)
                
            case .delete:
                button.setImage(UIImage(named: "btn_delete"), for: .normal)
                
            case .close:
                button.setImage(UIImage(named: "btn_clear"), for: .normal)
            }
            
            return button
        }
        
        var action: Action {
            switch self {
            case .back:
                return .back
                
            case .home:
                return .home
                
            case .delete:
                return .delete
                
            case .history:
                return .history
                
            case .search:
                return .search
                
            case .setting:
                return .setting
                
            case .share:
                return .share
                
            case .close:
                return .close
            }
        }
    }
    
    // MARK: - view properties
    let backButton: UIButton = {
        let view = ButtonType.back.button
        return view
    }()
    
    private var additionalTextLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.isUserInteractionEnabled = true
        
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        
        // Create tap gesture recognizer
        view.addGestureRecognizer(UITapGestureRecognizer())
        
        return view
    }()
    
    private lazy var additionalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5.adjust()
        return view
    }()
    
    // MARK: - properties
    var additionalButtons: [ButtonType] = [] {
        didSet { setAdditionalButton(types: additionalButtons) }
    }
    var additionalAttributedText: NSAttributedString? {
        didSet {
            guard let attributedText = additionalAttributedText else { return }
            setAdditionalAttributedText(attributedText)
        }
    }
    
    private(set) lazy var buttons: [ButtonType: UIButton] = [.back: backButton]
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 75.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.required, for: .vertical)
        backgroundColor = Constants.Color.alabaster
        
        // Set consraint of subviews
        addAutolayoutSubviews([backButton, titleLabel, additionalStackView])
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(backButton.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(14.adjust()).priority(.high)
            make.trailing.equalTo(additionalStackView.snp.leading).offset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
        additionalStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(36)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    override func bind() {
        // Additional button tap
        Observable.merge(buttons.values.map { button in
            button.rx.tap.compactMap { ButtonType(rawValue: button.tag)?.action }
        })
            .bind(to: action)
            .disposed(by: disposeBag)
        
        if let gestures = additionalTextLabel.gestureRecognizers {
            // Additional text tap
            Observable.merge(gestures.map { $0.rx.event.asObservable() })
                .map { _ in .additional }
                .bind(to: action)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - private method
    private func setAdditionalButton(types: [ButtonType]) {
        // Remove all buttons
        additionalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add all header buttons
        types.forEach { type in
            let button: UIButton
            if let reusableButton = self.buttons[type] {
                button = reusableButton
            } else {
                // Make new button
                button = type.button
                button.addTarget(self, action: #selector(touchButton(sender:)), for: .touchUpInside)
            }
            
            // Set constraint of subviews
            additionalStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(36.adjust())
            }
            
            self.buttons[type] = button
        }
        
        // Create new dispose bag to dispose reactive stream
        disposeBag = DisposeBag()
    }
    
    private func setAdditionalAttributedText(_ attributedText: NSAttributedString) {
        additionalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        additionalStackView.addArrangedSubview(additionalTextLabel)
        
        additionalTextLabel.attributedText = additionalAttributedText
        
        // Create new dispose bag to dispose reactive stream
        disposeBag = DisposeBag()
    }
    
    // MARK: - selector
    /// Animate key pad dumping when touched
    @objc private func touchButton(sender: UIButton) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, 1.2, 1]
        animation.keyTimes = [0, 0.5, 1.0]
        animation.duration = 0.2
        
        sender.layer.add(animation, forKey: "touch")
    }
}

extension Reactive where Base: CommonHeader {
    var additionalButtons: Binder<[Base.ButtonType]> {
        return Binder(base) { header, buttons in header.additionalButtons = buttons }
    }
    
    var additionalText: Binder<NSAttributedString> {
        return Binder(base) { header, attributedText in header.additionalAttributedText = attributedText }
    }
}
