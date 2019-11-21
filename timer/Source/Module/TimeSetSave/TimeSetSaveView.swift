//
//  TimeSetSaveView.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetSaveView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "time_set_save_title".localized
        return view
    }()
    
    lazy var titleTextField: UITextField = {
        let view = UITextField()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .left
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        view.inputAccessoryView = keyboardAccessoryView
        return view
    }()
    
    let titleClearButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_clear_mini"), for: .normal)
        view.isHidden = true
        return view
    }()
    
    let titleHintLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = Constants.Font.ExtraBold.withSize(24.adjust())
        view.textColor = Constants.Color.silver
        view.textAlignment = .left
        return view
    }()
    
    private let titleInputBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.carnation
        return view
    }()
    
    private lazy var titleInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleHintLabel, titleClearButton, titleTextField, titleInputBottomLineView])
        titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8.adjust())
            make.trailing.equalTo(titleClearButton.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        titleClearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(titleClearButton.snp.width)
        }
        
        titleHintLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8.adjust())
            make.trailing.equalTo(titleClearButton.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        titleInputBottomLineView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_all_time_title".localized
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var allTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeTitleLabel, allTimeLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        allTimeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    let endOfTimeSetTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_end_time_title".localized
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var endOfTimeSetStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [endOfTimeSetTitleLabel, endOfTimeSetLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        endOfTimeSetTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    let alarmTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_alarm_title".localized
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var alarmStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [alarmTitleLabel, alarmLabel])
        view.axis = .horizontal
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        alarmTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        return view
    }()
    
    let commentTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(15.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_comment_title".localized
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Constants.Color.clear
        view.isEditable = false
        view.isSelectable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
    
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.adjust()
        
        view.typingAttributes = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.doveGray,
            .kern: -0.45,
            .paragraphStyle: paragraphStyle
        ]
        return view
    }()
    
    private lazy var commentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentTitleLabel, commentTextView])
        view.axis = .horizontal
        view.alignment = .top
        view.spacing = 18.adjust()
        
        // Set constraint of subviews
        commentTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(74.adjust())
        }
        
        commentTextView.snp.makeConstraints { make in
            make.height.equalTo(72.adjust())
        }
        
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeStackView, endOfTimeSetStackView, alarmStackView, commentStackView])
        view.axis = .vertical
        view.spacing = 15.adjust()
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView(frame: .zero)
        if let layout = view.collectionViewLayout as? TimerBadgeCollectionViewFlowLayout {
            layout.axisPoint = CGPoint(x: 60.adjust(), y: 0)
            layout.axisAlign = .left
        }
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleInputView, infoStackView, timerBadgeCollectionView])
        titleInputView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(60.adjust()).priorityHigh()
            make.trailing.equalToSuperview()
            make.height.equalTo(50.adjust())
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleInputView.snp.bottom).offset(22.adjust())
            make.leading.equalTo(titleInputView)
            make.trailing.equalTo(titleInputView).inset(20.adjust())
        }
        
        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(20.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    let cancelButton: FooterButton = {
        return FooterButton(title: "footer_button_cancel".localized, type: .sub)
    }()
    
    let confirmButton: FooterButton = {
        return FooterButton(title: "footer_button_confirm".localized, type: .highlight)
    }()
    
    private lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [cancelButton, confirmButton]
        return view
    }()
    
    private let keyboardAccessoryView: UIToolbar = {
        let view = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 0)))
        view.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "keyboard_accessory_done_title".localized, style: .done, target: self, action: #selector(touchTitleDone(_:)))

        view.items = [flexibleSpace, doneButton]
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        addAutolayoutSubviews([headerView, contentView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priorityHigh()
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - selector
    @objc private func touchTitleDone(_ sender: UIBarButtonItem) {
        titleTextField.endEditing(true)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TimeSetSavePreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TimeSetSaveView {
        return TimeSetSaveView()
    }
    
    func updateUIView(_ uiView: TimeSetSaveView, context: Context) {
        // Nothing
    }
}

struct Previews_TimeSetSaveView: PreviewProvider {
    static var previews: some View {
        Group {
            TimeSetSavePreview()
                .previewDevice("iPhone 6s")
            
            TimeSetSavePreview()
                .previewDevice("iPhone 11")
        }
    }
}

#endif
