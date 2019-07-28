//
//  TimerOptionView.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimerOptionView: UIView {
    // MARK: - view properties
    let commentTextView: UITextView = {
        let view = UITextView()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        return view
    }()
    
    let commentLengthLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Light.withSize(12.adjust())
        return view
    }()
    
    let commentHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.lightGray
        view.text = "timer_option_comment_hint".localized
        return view
    }()
    
    private lazy var commentInputView: UIView = {
        let view = UIView()
        
        view.addAutolayoutSubviews([commentTextView, commentLengthLabel, commentHintLabel])
        // Set constarint of subviews
        commentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10.adjust())
            make.leading.equalToSuperview().inset(10.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
        }
        
        commentLengthLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTextView.snp.bottom).offset(10.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview().inset(10.adjust())
        }
        
        commentHintLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTextView).offset(commentTextView.textContainerInset.top)
            make.leading.equalTo(commentTextView).offset(commentTextView.textContainer.lineFragmentPadding)
        }
        
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        // TODO: remove it after resource applied
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    let alarmNameLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        return view
    }()
    
    let alarmApplyAllButton: UIButton = {
        let view = UIButton()
        let string = "timer_option_alarm_all_apply".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: Constants.Font.Regular.withSize(13.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        return view
    }()
    
    let alarmChangeButton: UIButton = {
        let view = UIButton()
        let string = "timer_option_alarm_change".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: Constants.Font.Regular.withSize(13.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        return view
    }()
    
    private lazy var alarmSettingView: UIView = {
        let view = UIView()
        
        view.addAutolayoutSubviews([alarmIconImageView, alarmNameLabel, alarmApplyAllButton, alarmChangeButton])
        // Set constarint of subviews
        alarmIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(alarmIconImageView.snp.height)
        }

        alarmNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(alarmIconImageView.snp.trailing)
            make.trailing.equalTo(alarmApplyAllButton.snp.leading)
            make.bottom.equalToSuperview()
        }

        alarmApplyAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(alarmChangeButton.snp.leading).offset(-10.adjust())
            make.bottom.equalToSuperview()
            make.width.equalTo(alarmApplyAllButton.titleLabel!.sizeThatFits(.zero).width)
        }

        alarmChangeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10.adjust())
            make.bottom.equalToSuperview()
            make.width.equalTo(alarmChangeButton.titleLabel!.sizeThatFits(.zero).width)
        }
        
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        // TODO: remove it after resource applied
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        return view
    }()
        
    let deleteButton: UIButton = {
        let view = UIButton()
        // TODO: remove it after resource applied
        view.backgroundColor = UIColor.green
        return view
    }()
    
    private lazy var timerInfoView: UIView = {
        let view = UIView()
        
        view.addAutolayoutSubviews([timerIconImageView, titleLabel, deleteButton])
        // Set constarint of subviews
        timerIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(timerIconImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(timerIconImageView.snp.trailing)
            make.trailing.equalTo(deleteButton.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(deleteButton.snp.height)
        }
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentInputView, alarmSettingView, timerInfoView])
        view.axis = .vertical
        
        // Set constarint of subviews
        alarmSettingView.snp.makeConstraints { make in
            make.height.equalTo(50.adjust())
        }
        
        timerInfoView.snp.makeConstraints { make in
            make.height.equalTo(50.adjust())
        }
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubview(contentStackView)
        // Set constarint of subviews
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
