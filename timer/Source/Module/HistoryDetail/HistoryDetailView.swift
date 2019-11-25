//
//  HistoryDetailView.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class HistoryDetailView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "history_detail_title".localized
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let runningTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_all_time_title".localized
        return view
    }()
    
    let runningTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var runningTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [runningTimeTitleLabel, runningTimeLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        runningTimeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    private let dateTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "history_date_title".localized
        return view
    }()
    
    let dateLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var dateStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dateTitleLabel, dateLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        dateTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    private let extraTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "history_extra_time_title".localized
        return view
    }()
    
    let extraTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var extraTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [extraTimeTitleLabel, extraTimeLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        extraTimeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    private let repeatCountTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "history_repeat_count_title".localized
        return view
    }()
    
    let repeatCountLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var repeatCountStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [repeatCountTitleLabel, repeatCountLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        repeatCountTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [runningTimeStackView, dateStackView, extraTimeStackView, repeatCountStackView])
        view.axis = .vertical
        view.spacing = 9.adjust()
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
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let memoHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.silver
        view.text = "time_set_memo_hint".localized
        return view
    }()
    
    private let memoIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_memo"))
        return view
    }()
    
    private lazy var memoInputView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.gallery
        view.layer.cornerRadius = 20.adjust()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([memoIconImageView, memoTextView, memoExcessLabel, memoLengthLabel, memoHintLabel])
        memoIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2.adjust())
            make.leading.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(memoIconImageView.snp.width)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(13.adjust())
            make.leading.equalTo(memoIconImageView.snp.trailing).inset(2.adjust())
            make.trailing.equalToSuperview().inset(11.adjust()).priorityHigh()
            make.bottom.equalToSuperview().inset(30.adjust()).priorityHigh()
        }
        
        memoExcessLabel.snp.makeConstraints { make in
            make.leading.equalTo(memoTextView)
            make.trailing.equalTo(memoLengthLabel.snp.leading).inset(-10.adjust())
            make.centerY.equalTo(memoLengthLabel)
        }
        
        memoLengthLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(10.adjust())
            make.trailing.equalToSuperview().inset(21.adjust())
        }
        
        memoHintLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTextView)
            make.leading.equalTo(memoTextView)
        }
        
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView()
        if let layout = view.collectionViewLayout as? TimerBadgeCollectionViewFlowLayout {
            layout.axisPoint = CGPoint(x: 60.adjust(), y: 0)
            layout.axisAlign = .left
        }
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, divider, infoStackView, memoInputView, timerBadgeCollectionView])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(divider)
            make.trailing.equalToSuperview().inset(20.adjust()).priorityHigh()
            make.bottom.equalTo(divider.snp.top).inset(-13.adjust())
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(49.adjust())
            make.leading.equalToSuperview().inset(60.adjust()).priorityHigh()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(14.adjust())
            make.leading.equalTo(divider)
            make.trailing.equalToSuperview().inset(20.adjust()).priorityHigh()
        }
        
        memoInputView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(61.adjust())
            make.leading.equalTo(divider)
            make.trailing.equalToSuperview().inset(20.adjust())
            make.bottom.equalTo(timerBadgeCollectionView.snp.top).inset(-20.adjust()).priorityHigh()
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(65.adjust())
        }
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = false
        
        // Set constraint of subviews
        view.addAutolayoutSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        return view
    }()
    
    let saveButton: FooterButton = {
        return FooterButton(title: "footer_button_save".localized, type: .sub)
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .normal)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [saveButton, startButton]
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
        addAutolayoutSubviews([headerView, scrollView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        // Add tap gesture in scroll view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(gesture:)))
        scrollView.addGestureRecognizer(tapGesture)
        
        // Observe keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - selector
    @objc func scrollViewTapped(gesture: UITapGestureRecognizer) {
        endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset.y = 60
        }
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset.y = 0
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
