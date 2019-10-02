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
        case bookmark
        case share
        case delete
        
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
            case .bookmark:
                button.setImage(UIImage(named: "btn_bookmark_off"), for: .normal)
                button.setImage(UIImage(named: "btn_bookmark_on"), for: .selected)
            case .share:
                button.setImage(UIImage(named: "btn_share"), for: .normal)
            case .delete:
                button.setImage(UIImage(named: "btn_delete"), for: .normal)
            }
            
            return button
        }
        
        var action: Action {
            switch self {
            case .back:
                return .back
            case .home:
                return .home
            case .bookmark:
                return .bookmark
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
            }
        }
    }
    
    // MARK: - view properties
    let backButton: UIButton = {
        let view = ButtonType.back.button
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(18.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private lazy var additionalButtonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5.adjust()
        return view
    }()
    
    private var additionalTextLabel: UILabel = {
        let view = UILabel()
        view.isUserInteractionEnabled = true
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.isHidden = true
        return view
    }()
    
    // MARK: - properties
    override var title: String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }
    var additionalButtons: [ButtonType] = [] {
        didSet { setAdditionalButton(types: additionalButtons) }
    }
    var additionalAttributedText: NSAttributedString? {
        didSet { setAdditionalAttributedText(additionalAttributedText) }
    }
    
    lazy var buttons: [ButtonType: UIButton] = [.back: backButton]
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 75.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set consraint of subviews
        addAutolayoutSubviews([backButton, titleLabel, additionalButtonsStackView, additionalTextLabel])
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(backButton.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(14.adjust()).priorityHigh()
            make.trailing.equalTo(additionalButtonsStackView.snp.leading).offset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
        additionalButtonsStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            // Set minimum stack view size if arranged views are empty
            make.width.equalTo(36).priorityHigh()
            make.height.equalTo(36).priorityHigh()
        }
        
        additionalTextLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.adjust())
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    override func bind() {
        buttons.values.forEach { button in
            button.rx.tap
                .flatMap { () -> Observable<Action> in
                    guard let type = ButtonType(rawValue: button.tag) else { return .empty() }
                    return .just(type.action)
                }
                .bind(to: action)
                .disposed(by: self.disposeBag)
        }
        
        // Remove additional text label gesture recognizer
        additionalTextLabel.gestureRecognizers?.forEach { additionalTextLabel.removeGestureRecognizer($0) }
        // Create new tap gesture recognizer
        let tapGesture = UITapGestureRecognizer()
        additionalTextLabel.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map { _ in .additional }
            .bind(to: action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func setAdditionalButton(types: [ButtonType]) {
        guard !types.isEmpty else { return }
        
        additionalButtonsStackView.isHidden = false
        additionalTextLabel.isHidden = true
        
        // Remake title constraint
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(14.adjust()).priorityHigh()
            make.trailing.equalTo(additionalButtonsStackView.snp.leading).offset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
        // Remove all buttons
        additionalButtonsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            
            // Remove buttons in button stack view from `buttons`
            guard let buttonType = ButtonType(rawValue: $0.tag) else { return }
            self.buttons[buttonType] = nil
        }
        
        // Add all header buttons
        types.forEach { type in
            let button = type.button
            
            button.addTarget(self, action: #selector(touchButton(sender:)), for: .touchUpInside)
            
            // Set constraint of subviews
            additionalButtonsStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(36.adjust())
            }
            
            self.buttons[type] = button
        }
        
        // Create new dispose bag to dispose reactive stream
        disposeBag = DisposeBag()
    }
    
    private func setAdditionalAttributedText(_ attributedText: NSAttributedString?) {
        guard attributedText != nil else { return }
        
        additionalButtonsStackView.isHidden = true
        additionalTextLabel.isHidden = false
        
        // Remake title constraint
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(14.adjust()).priorityHigh()
            make.trailing.equalTo(additionalTextLabel.snp.leading).offset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
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
    var additionalText: Binder<NSAttributedString> {
        return Binder(base) { _, attributedText in self.base.additionalAttributedText = attributedText }
    }
}
