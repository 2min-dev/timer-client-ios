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
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let stateLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let timeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(50.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let memoButton: RoundButton = {
        let view = RoundButton(title: "time_set_process_memo_title".localized, image: UIImage(named: "icon_memo"))
        view.backgroundColor = Constants.Color.gallery
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let repeatButton: RoundButton = {
        let view = RoundButton(image: UIImage(named: "btn_repeat_off"))
        view.backgroundColor = Constants.Color.gallery
        view.setImage(UIImage(named: "btn_repeat_on"), for: .selected)
        return view
    }()
    
    let addTimeButton: RoundButton = {
        let view = RoundButton(title: "time_set_process_add_time_title".localized)
        view.backgroundColor = Constants.Color.gallery
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [memoButton, repeatButton, addTimeButton])
        view.axis = .horizontal
        view.spacing = 15.adjust()
        return view
    }()
    
    let extraTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.ExtraBold.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_all_time_title".localized
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var allTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeTitleLabel, allTimeLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        allTimeTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let endOfTimeSetTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "time_set_end_time_title".localized
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var endOfTimeSetStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [endOfTimeSetTitleLabel, endOfTimeSetLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        endOfTimeSetTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let alarmTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_alarm_title".localized
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        return view
    }()
    
    private lazy var alarmStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [alarmTitleLabel, alarmLabel])
        view.axis = .horizontal
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        alarmTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        return view
    }()
    
    let commentTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Bold.withSize(12.adjust())
        view.textColor = Constants.Color.doveGray
        view.text = "timer_comment_title".localized
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Constants.Color.clear
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.isEditable = false
        view.isSelectable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
    
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.adjust()
        
        view.typingAttributes = [.foregroundColor: Constants.Color.doveGray,
                                 .paragraphStyle: paragraphStyle]
        return view
    }()
    
    private lazy var commentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentTitleLabel, commentTextView])
        view.axis = .horizontal
        view.alignment = .top
        view.spacing = 20.adjust()
        
        // Set constraint of subviews
        commentTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(60.adjust())
        }
        
        commentTextView.snp.makeConstraints { make in
            make.height.equalTo(56.adjust())
        }
        
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [allTimeStackView, endOfTimeSetStackView, alarmStackView, commentStackView])
        view.axis = .vertical
        view.spacing = 10.adjust()
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
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([titleLabel, stateLabel, timeLabel, repeatButton, addTimeButton, extraTimeLabel, infoStackView, timerBadgeCollectionView, dimedView, memoButton])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(85.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalToSuperview().inset(10.adjust())
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(102.adjust())
            make.leading.equalTo(timeLabel)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(124.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview()
        }
        
        memoButton.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10.adjust()).priorityHigh()
            make.leading.equalTo(timeLabel)
        }
        
        repeatButton.snp.makeConstraints { make in
            make.leading.equalTo(memoButton.snp.trailing).offset(10.adjust())
            make.centerY.equalTo(memoButton)
        }
        
        addTimeButton.snp.makeConstraints { make in
            make.leading.equalTo(repeatButton.snp.trailing).offset(10.adjust())
            make.centerY.equalTo(repeatButton)
        }
        
        extraTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(addTimeButton.snp.trailing).offset(5.adjust())
            make.centerY.equalTo(addTimeButton)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(123.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalToSuperview().inset(20.adjust())
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(8.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        dimedView.snp.makeConstraints { make in
            make.top.equalTo(memoButton)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let startButton: FooterButton = {
        return FooterButton(title: "footer_button_start".localized, type: .highlight)
    }()
    
    let stopButton: FooterButton = {
        return FooterButton(title: "footer_button_cancel".localized, type: .sub)
    }()
    
    let quitButton: FooterButton = {
        return FooterButton(title: "footer_button_quit".localized, type: .sub)
    }()
    
    let pauseButton: FooterButton = {
        return FooterButton(title: "footer_button_pause".localized, type: .normal)
    }()
    
    lazy var footerView: Footer = {
        let view = Footer()
        view.buttons = [stopButton, pauseButton]
        return view
    }()
    
    let dimedView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.alabaster
        view.alpha = 0
        return view
    }()
    
    // MARK: - properties
    var isEnabled: Bool = true {
        didSet {
            dimedView.alpha = isEnabled ? 0 : 0.8
        }
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([contentView, footerView])
        contentView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().priorityHigh()
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
