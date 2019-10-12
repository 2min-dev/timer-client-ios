//
//  TimeSetMemoView.swift
//  timer
//
//  Created by JSilver on 25/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetMemoView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.additionalButtons = [.close]
        view.title = "time_set_memo_title".localized
        view.backButton.isHidden = true
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
        paragraphStyle.lineSpacing = 8.adjust()
        
        view.typingAttributes = [.font: Constants.Font.Regular.withSize(12.adjust()),
                                 .foregroundColor: Constants.Color.codGray,
                                 .paragraphStyle: paragraphStyle]
        return view
    }()
    
    let memoExcessLabel: UILabel = {
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
    
    let memoHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        view.text = "time_set_memo_hint".localized
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
            make.trailing.equalToSuperview().inset(20.adjust())
            make.bottom.equalTo(divider.snp.top).inset(-10.adjust())
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
            make.leading.equalTo(memoTextView)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(memoTextView)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(memoLengthLabel.snp.top).inset(-10.adjust())
            make.height.equalTo(0.5)
        }
        
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
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, memoInputView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        memoInputView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview()
            make.height.equalTo(265.adjust())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - selector
    @objc private func touchCommentDone(_ sender: UIBarButtonItem) {
        memoTextView.endEditing(true)
    }
}
