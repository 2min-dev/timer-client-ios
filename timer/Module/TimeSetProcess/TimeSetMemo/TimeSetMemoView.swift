//
//  TimeSetMemoView.swift
//  timer
//
//  Created by JSilver on 25/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

class TimeSetMemoView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.additionalButtons = [.share, .bookmark, .home]
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
    
    private lazy var timeSetInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, timeLabel, divider])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12.adjust())
            make.leading.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10.adjust())
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
    
    let memoLengthExcessLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.carnation
        view.text = "time_set_memo_excess_title".localized
        return view
    }()
    
    let memoLengthLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let memoHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        view.text = "time_set_memo_hint".localized
        return view
    }()
    
    private lazy var memoInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([memoTextView, memoLengthExcessLabel, memoLengthLabel, memoHintLabel])
        memoTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20.adjust())
        }
        
        memoLengthExcessLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(memoLengthLabel.snp.leading).inset(-10.adjust())
            make.centerY.equalTo(memoLengthLabel)
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
    
    let cancelButton: FooterButton = {
        return FooterButton(title: "footer_button_cancel".localized, type: .normal)
    }()
    
    let pauseButton: FooterButton = {
        return FooterButton(title: "footer_button_pause".localized, type: .highlight)
    }()
    
    let restartButton: FooterButton = {
        return FooterButton(title: "footer_button_restart".localized, type: .highlight)
    }()
    
    private lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [cancelButton, pauseButton]
        return view
    }()
    
    // MARK: - properties
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Observe keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, timeSetInfoView, memoInputView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        timeSetInfoView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(35.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview()
        }
        
        memoInputView.snp.makeConstraints { make in
            make.top.equalTo(timeSetInfoView.snp.bottom)
            make.leading.equalTo(timeSetInfoView)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).inset(-56.adjust())
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    private func bind() {
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - selector
    @objc func keyboardWillShow(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.memoInputView.snp.updateConstraints { make in
                make.bottom.equalTo(self.footerView.snp.top).inset(-194.adjust())
            }
            
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.memoInputView.snp.updateConstraints { make in
                make.bottom.equalTo(self.footerView.snp.top).inset(-56.adjust())
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
