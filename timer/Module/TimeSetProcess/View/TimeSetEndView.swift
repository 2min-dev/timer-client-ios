//
//  TimeSetEndView.swift
//  timer
//
//  Created by JSilver on 21/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

class TimeSetEndView: UIView {
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
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text. remove it
        view.text = "내 타임셋 종료"
        return view
    }()
    
    let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(50.adjust())
        view.textColor = Constants.Color.codGray
        // TODO: sample text. remove it
        view.text = "00:00:00"
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    let timerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.textColor = Constants.Color.doveGray
        // TODO: sample text. remove it
        view.text = "2/2 (N회 반복)"
        return view
    }()
    
    private lazy var timeSetInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, timeLabel, timerIconImageView, timerLabel, divider])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12.adjust())
            make.leading.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2.adjust())
            make.trailing.equalTo(timerLabel.snp.leading).offset(3.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(timerIconImageView.snp.width)
        }
        
        timerLabel.snp.makeConstraints { make in
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
        // TODO: sample text. remove it
        view.text = "0/1000 bytes"
        return view
    }()
    
    let memoHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        // TODO: sample text. remove it
        view.text = "메모를 입력하세요."
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
    
    // MARK: - properties
    private var disposeBag = DisposeBag()
    
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
        addAutolayoutSubviews([headerView, timeSetInfoView, memoInputView])
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
            make.height.equalTo(190.adjust())
        }
        
        bind()
    }
    
    convenience init(isShow: Bool) {
        self.init(frame: .zero)
        show(isShow, animated: false)
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
    
    // MARK: - public method
    func show(_ isShow: Bool, animated: Bool) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        var frame = self.frame
        if isShow {
            frame.origin.y = 49.adjust()
            if #available(iOS 11.0, *) {
                frame.origin.y += keyWindow.safeAreaInsets.top
            }
        } else {
            frame.origin.y = keyWindow.bounds.height
        }
        
        if animated {
            UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                self.frame = frame
            }.startAnimation()
        } else {
            self.frame = frame
        }
    }
}
