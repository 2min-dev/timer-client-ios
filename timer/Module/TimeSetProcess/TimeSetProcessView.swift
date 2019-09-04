//
//  TimeSetProcessView.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetProcessView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.buttonTypes = [.share, .bookmark, .home]
        return view
    }()
    
    let timeSetBadge: TimeSetBadge = {
        let view = TimeSetBadge()
        view.font = Constants.Font.Bold.withSize(10.adjust())
        view.setBadgeType(.countdown(time: 0))
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
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
    
    private let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "time_set_all_time_full_title".localized
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let extraTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.carnation
        return view
    }()
    
    private let endOfTimeSetTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "time_set_end_time_full_title".localized
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let repeatButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_repeat_off"), for: .normal)
        view.setImage(UIImage(named: "btn_repeat_on"), for: .selected)
        view.setImage(UIImage(named: "btn_repeat_disable"), for: .disabled)
        return view
    }()
    
    let addTimeButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = Constants.Font.Bold.withSize(12.adjust())
        view.setTitleColor(Constants.Color.codGray, for: .normal)
        view.setTitleColor(Constants.Color.silver, for: .disabled)
        view.setTitle("time_set_add_time_title".localized, for: .normal)
        return view
    }()
    
    private lazy var timeSetInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.codGray
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([allTimeTitleLabel, allTimeLabel, extraTimeLabel, endOfTimeSetTitleLabel, endOfTimeSetLabel, addTimeButton, repeatButton, divider])
        allTimeTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(11.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalTo(endOfTimeSetTitleLabel)
        }
        
        allTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(allTimeTitleLabel)
            make.leading.equalTo(allTimeTitleLabel.snp.trailing).offset(10.adjust())
            make.bottom.equalTo(allTimeTitleLabel)
        }
        
        extraTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(allTimeLabel.snp.trailing).offset(5.adjust())
            make.centerY.equalTo(allTimeLabel)
        }
        
        endOfTimeSetTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(allTimeTitleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(16.adjust())
        }
        
        endOfTimeSetLabel.snp.makeConstraints { make in
            make.top.equalTo(endOfTimeSetTitleLabel)
            make.leading.equalTo(endOfTimeSetTitleLabel.snp.trailing).offset(10.adjust())
            make.bottom.equalTo(endOfTimeSetTitleLabel)
        }
        
        addTimeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(addTimeButton.snp.width)
        }

        repeatButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(addTimeButton.snp.leading).offset(-10.adjust())
            make.width.equalTo(36.adjust())
            make.height.equalTo(addTimeButton.snp.width)
        }

        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    let memoButton: MemoButton = {
        let view = MemoButton()
        return view
    }()
    
    let timerBadgeCollectionView: TimerBadgeCollectionView = {
        let view = TimerBadgeCollectionView()
        view.layout?.axisPoint = CGPoint(x: 60.adjust(), y: 0)
        view.layout?.axisAlign = .left
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_sound")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = Constants.Color.codGray
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private lazy var alarmView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([alarmIconImageView, alarmLabel])
        alarmIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(alarmIconImageView.snp.width)
        }
        
        alarmLabel.snp.makeConstraints { make in
            make.leading.equalTo(alarmIconImageView.snp.trailing).offset(5.adjust())
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        return view
    }()
    
    private let commentIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_comment")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = Constants.Color.codGray
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        // Remove padding
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.isEditable = false
        return view
    }()
    
    private lazy var commentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([commentIconImageView, commentTextView])
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(commentIconImageView.snp.width)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(11.33.adjust())
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5.adjust())
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([timeSetBadge, titleLabel, timeLabel, timeSetInfoView, timerBadgeCollectionView, memoButton, alarmView, commentView])
        timeSetBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5.adjust())
            make.leading.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(35.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.adjust())
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        timeSetInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(247.adjust())
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(timeSetInfoView.snp.bottom).offset(8.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        memoButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(timerBadgeCollectionView)
        }

        alarmView.snp.makeConstraints { make in
            make.top.equalTo(timerBadgeCollectionView.snp.bottom).offset(14.adjust())
            make.leading.equalToSuperview().inset(50.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
        }

        commentView.snp.makeConstraints { make in
            make.top.equalTo(alarmView.snp.bottom).inset(9.adjust())
            make.leading.equalToSuperview().inset(50.adjust())
            make.trailing.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let editButton: FooterButton = {
        return FooterButton(title: "footer_button_edit".localized, type: .normal)
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .highlight)
    }()
    
    let stopButton: FooterButton = {
        return FooterButton(title: "footer_button_cancel".localized, type: .normal)
    }()
    
    let quitButton: FooterButton = {
        return FooterButton(title: "footer_button_quit".localized, type: .normal)
    }()
    
    let pauseButton: FooterButton = {
        return FooterButton(title: "footer_button_pause".localized, type: .highlight)
    }()
    
    let restartButton: FooterButton = {
        return FooterButton(title: "footer_button_restart".localized, type: .highlight)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [stopButton, pauseButton]
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubviews([headerView, contentView, footerView])
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).offset(-10.adjust())
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
    
    // MARK: - public method
    /// Set layout enable/disable
    func setEnable(_ isEnabled: Bool) {
        // Set color of view by type
        func setColor(view: UIView) {
            if let imageView = view as? UIImageView {
                imageView.tintColor = isEnabled ? Constants.Color.codGray : Constants.Color.silver
            } else if let button = view as? UIButton {
                button.isEnabled = isEnabled
            } else if let label = view as? UILabel {
                label.textColor = isEnabled ? Constants.Color.codGray : Constants.Color.silver
            } else if let textView = view as? UITextView {
                textView.textColor = isEnabled ? Constants.Color.codGray : Constants.Color.silver
            } else {
                view.backgroundColor = isEnabled ? Constants.Color.codGray : Constants.Color.gallery
            }
        }
        
        timeSetInfoView.subviews.forEach { setColor(view: $0) }
        alarmView.subviews.forEach { setColor(view: $0) }
        commentView.subviews.forEach { setColor(view: $0) }
        
        // Set add time button title color
        addTimeButton.titleLabel?.textColor = isEnabled ? Constants.Color.carnation : Constants.Color.silver
        
        timerBadgeCollectionView.isEnabled = isEnabled
        memoButton.isEnabled = isEnabled
    }
}
