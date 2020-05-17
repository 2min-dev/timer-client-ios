//
//  TimeSetEndView.swift
//  timer
//
//  Created by JSilver on 21/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEndView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.additionalButtons = [.close]
        view.title = "time_set_end_title".localized
        view.backButton.isHidden = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    lazy var memoTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Constants.Color.clear
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.textContainer.lineFragmentPadding = 0
        
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        view.inputAccessoryView = keyboardAccessoryView
        
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.2.adjust()
        
        view.typingAttributes = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .kern: -0.45,
            .paragraphStyle: paragraphStyle
        ]
        
        return view
    }()
    
    let memoExcessLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.carnation
        view.text = "time_set_memo_excess_title".localized
        return view
    }()
    
    let memoLengthLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let memoHintLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.2.adjust()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.silver,
            .kern: -0.45,
            .paragraphStyle: paragraphStyle
        ]
        
        view.attributedText = NSAttributedString(string: "time_set_memo_hint".localized, attributes: attributes)
        return view
    }()
    
    private lazy var memoInputView: UIView = {
        let view = UIView()
        
        let divider: UIView = UIView()
        divider.backgroundColor = Constants.Color.doveGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([memoTextView, memoExcessLabel, memoLengthLabel, memoHintLabel, divider])
        memoTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20.adjust()).priority(.high)
            make.bottom.equalTo(divider.snp.top).inset(-3.adjust())
        }
        
        memoExcessLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(memoLengthLabel.snp.leading).inset(-10.adjust())
            make.centerY.equalTo(memoLengthLabel)
        }
        
        memoLengthLabel.snp.makeConstraints { make in
            make.trailing.equalTo(memoTextView)
            make.bottom.equalToSuperview()
        }
        
        memoHintLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView)
            make.leading.trailing.equalTo(memoTextView)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(memoTextView)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(memoLengthLabel.snp.top).inset(-10.adjust())
            make.height.equalTo(0.5)
        }
        
        return view
    }()
    
    let overtimeButton: FooterButton = {
        FooterButton(title: "footer_button_overtime".localized, type: .sub)
    }()
    
    let saveButton: FooterButton = {
        FooterButton(title: "footer_button_save".localized, type: .normal)
    }()
    
    let restartButton: FooterButton = {
        FooterButton(title: "footer_button_restart".localized, type: .normal)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [overtimeButton, saveButton, restartButton]
        return view
    }()
    
    private let keyboardAccessoryView: UIToolbar = {
        let view = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 0)))
        view.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "keyboard_accessory_done_title".localized, style: .done, target: self, action: #selector(touchCommentDone(_:)))
        
        view.items = [flexibleSpace, doneButton]
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, titleLabel, dateLabel, memoInputView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(5.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().inset(20.adjust()).priority(.high)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(27.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().inset(20.adjust()).priority(.high)
        }
        
        memoInputView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(57.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().priority(.high)
            make.height.equalTo(175.adjust())
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // Observe keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - selector
    @objc func keyboardWillShow(sender: Notification) {
        guard let frame = sender.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
        UIView.animate(withDuration: 0.3) {
            self.footerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(frame.height)
            }

            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.footerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }

            self.layoutIfNeeded()
        }
    }
    
    @objc private func touchCommentDone(_ sender: UIBarButtonItem) {
        memoTextView.endEditing(true)
    }
    
    deinit {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
