//
//  TimeSetEndView.swift
//  timer
//
//  Created by JSilver on 21/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class TimeSetEndView: UIView, View {
    // MARK: - view properties
    let downButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "icon_arrow_down"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear"), for: .normal)
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([downButton, closeButton])
        downButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15.adjust())
            make.leading.equalToSuperview().inset(10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(downButton.snp.width)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(closeButton.snp.width)
        }
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(50.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    let endInfoLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var timeSetInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, timeLabel, timerIconImageView, endInfoLabel, divider])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalTo(timerIconImageView.snp.leading)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2.adjust())
            make.trailing.equalTo(endInfoLabel.snp.leading).offset(3.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        endInfoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14.adjust())
            make.trailing.equalToSuperview().inset(20.adjust())
        }

        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    let memoTextView: UITextView = {
        let view = UITextView()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.textContainer.lineFragmentPadding = 0
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        return view
    }()
    
    let memoLengthLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let memoHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        view.text = "time_set_memo_hint".localized
        return view
    }()
    
    private lazy var memoInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([memoTextView, memoLengthLabel, memoHintLabel])
        memoTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20.adjust())
        }
        
        memoLengthLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(8.adjust())
            make.trailing.equalTo(memoTextView)
            make.bottom.equalToSuperview().inset(10.adjust())
        }
        
        memoHintLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView).offset(memoTextView.textContainerInset.top)
            make.leading.equalTo(memoTextView).offset(memoTextView.textContainer.lineFragmentPadding)
        }
        
        return view
    }()
    
    let excessButton: FooterButton = {
        return FooterButton(title: "footer_button_excess".localized, type: .normal)
    }()
    
    let restartButton: FooterButton = {
        return FooterButton(title: "footer_button_restart".localized, type: .highlight)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [excessButton, restartButton]
        return view
    }()
    
    private var dim: UIView?
    
    // MARK: - properties
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        var frame = frame
        if let keyWindow = UIApplication.shared.keyWindow {
            // Set view size if key window exist
            frame.size = CGSize(width: keyWindow.bounds.width, height: keyWindow.bounds.height - 49.adjust())
            if #available(iOS 11.0, *) {
                frame.size.height -= keyWindow.safeAreaInsets.top
            }
        }
        
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, timeSetInfoView, memoInputView, footerView])
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(51.adjust())
        }
        
        timeSetInfoView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview()
        }
        
        memoInputView.snp.makeConstraints { make in
            make.top.equalTo(timeSetInfoView.snp.bottom)
            make.leading.equalTo(timeSetInfoView)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).inset(-57.adjust())
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    convenience init(isShow: Bool) {
        self.init(frame: .zero)
        isShow ? show() : dismiss()
        
        // Observe keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(view: self, byRoundingCorners: [.topLeft, .topRight], cornerRadius: 20.adjust())
    }
    
    // MARK: - bind
    private func bind() {
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetEndViewReactor) {
        // Rebind view. because dispose bag is reallocated when reactor was assigned each time
        bind()
        
        // MARK: action
        memoTextView.rx.text
            .orEmpty
            .map { Reactor.Action.updateMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .map { String(format: "time_set_end_title_format".localized, $0) }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time
        reactor.state
            .map { $0.runningTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End info
        reactor.state
            .map { ($0.endIndex + 1, $0.timerCount, $0.repeatCount) }
            .distinctUntilChanged { $0 == $1 }
            .map { String(format: "time_set_end_info_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: endInfoLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Memo
        reactor.state
            .map { $0.memo }
            .filter { [weak self] in self?.memoTextView.text != $0 }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Memo length
        reactor.state
            .map { $0.memo }
            .map { $0.lengthOfBytes(using: .utf8) }
            .distinctUntilChanged()
            .map { String(format: "time_set_memo_bytes_format".localized, $0, TimeSetEndViewReactor.MAX_MEMO_LENGTH) }
            .bind(to: memoLengthLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - public method
    /// Show time set end view (bottom - up slide)
    func show(animated: Bool = false) {
        guard let keyWindow = UIApplication.shared.keyWindow, let superview = superview else { return }
        
        // Create dim
        dim = UIView(frame: superview.frame)
        dim?.backgroundColor = Constants.Color.codGray.withAlphaComponent(0)
        // Insert dim view below end view
        superview.insertSubview(dim!, belowSubview: self)
        
        // Calculate view position
        var frame = self.frame
        frame.origin.y = 49.adjust()
        if #available(iOS 11.0, *) {
            frame.origin.y += keyWindow.safeAreaInsets.top
        }
        
        if animated {
            // Show with animation
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.dim?.backgroundColor = Constants.Color.codGray.withAlphaComponent(0.8) // Dim animation
                self.frame = frame // End view animation
            }
            
            animator.startAnimation()
        } else {
            self.frame = frame
        }
    }
    
    /// Dismiss time set end view (top - down slide)
    func dismiss(animated: Bool = false) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        // Calculate view position
        var frame = self.frame
        frame.origin.y = keyWindow.bounds.height
        
        if animated {
            // Hide with animation
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.dim?.backgroundColor = Constants.Color.codGray.withAlphaComponent(0) // Dim animation
                self.frame = frame // End view animation
            }
            
            animator.addCompletion {
                if $0 == .end {
                    // Remove dim when animation ended
                    self.dim?.removeFromSuperview()
                }
            }
            
            animator.startAnimation()
        } else {
            self.frame = frame
        }
    }
    
    // MARK: - selector
    @objc func keyboardWillShow(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.memoInputView.snp.remakeConstraints { make in
                make.top.equalTo(self.timeSetInfoView.snp.bottom)
                make.leading.equalTo(self.timeSetInfoView)
                make.trailing.equalToSuperview()
                make.height.equalTo(190.adjust())
            }
            
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.memoInputView.snp.remakeConstraints { make in
                make.top.equalTo(self.timeSetInfoView.snp.bottom)
                make.leading.equalTo(self.timeSetInfoView)
                make.trailing.equalToSuperview()
                make.bottom.equalTo(self.footerView.snp.top).inset(-57.adjust())
            }
            
            self.layoutIfNeeded()
        }
    }
    
    deinit {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
