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
        view.font = R.Font.extraBold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let stateHighlightView: UIView = {
        let view = UIView()
        view.backgroundColor = R.Color.carnation
        view.layer.cornerRadius = 5.adjust()
        return view
    }()
    
    let stateLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    let timeLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.extraBold.withSize(50.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let memoButton: RoundButton = {
        let view = RoundButton(title: "time_set_process_memo_title".localized, image: R.Icon.icMemo)
        view.backgroundColor = R.Color.gallery
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let repeatButton: RoundButton = {
        let view = RoundButton(image: R.Icon.icBtnRepeatOff)
        view.backgroundColor = R.Color.gallery
        view.setImage(R.Icon.icBtnRepeatOn, for: .selected)
        return view
    }()
    
    let addTimeButton: RoundButton = {
        let view = RoundButton(title: "time_set_process_add_time_title".localized)
        view.backgroundColor = R.Color.gallery
        view.font = R.Font.bold.withSize(12.adjust())
        view.textColor = R.Color.codGray
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
        view.font = R.Font.extraBold.withSize(12.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let allTimeTitleLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.bold.withSize(15.adjust())
        view.textColor = R.Color.doveGray
        view.text = "time_set_all_time_title".localized
        return view
    }()
    
    let allTimeLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.regular.withSize(15.adjust())
        view.textColor = R.Color.doveGray
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
        view.font = R.Font.bold.withSize(15.adjust())
        view.textColor = R.Color.doveGray
        view.text = "time_set_end_time_title".localized
        return view
    }()
    
    let endOfTimeSetLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.regular.withSize(15.adjust())
        view.textColor = R.Color.doveGray
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
        view.font = R.Font.bold.withSize(15.adjust())
        view.textColor = R.Color.doveGray
        view.text = "timer_alarm_title".localized
        return view
    }()
    
    let alarmLabel: UILabel = {
        let view = UILabel()
        view.font = R.Font.regular.withSize(15.adjust())
        view.textColor = R.Color.doveGray
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
        view.font = R.Font.bold.withSize(15.adjust())
        view.textColor = R.Color.doveGray
        view.text = "timer_comment_title".localized
        return view
    }()
    
    let commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = R.Color.clear
        view.isEditable = false
        view.isSelectable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
    
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7.adjust()
        
        view.typingAttributes = [
            .font: R.Font.regular.withSize(15.adjust()),
            .foregroundColor: R.Color.doveGray,
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
        view.addAutolayoutSubviews([titleLabel, stateHighlightView, stateLabel, timeLabel, repeatButton, addTimeButton, extraTimeLabel, infoStackView, timerBadgeCollectionView, dimedView, memoButton])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50.adjust())
            make.leading.equalTo(timeLabel)
            make.trailing.equalToSuperview().inset(10.adjust())
        }
        
        stateHighlightView.snp.makeConstraints { make in
            make.centerY.equalTo(stateLabel)
            make.trailing.equalTo(stateLabel.snp.leading).inset(-5.adjust())
            make.width.equalTo(10.adjust())
            make.height.equalTo(stateHighlightView.snp.width)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72.adjust())
            make.leading.equalTo(timeLabel)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(94.adjust())
            make.leading.equalToSuperview().inset(60.adjust())
            make.trailing.equalToSuperview()
        }
        
        memoButton.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5.adjust()).priority(.high)
            make.leading.equalTo(timeLabel)
        }
        
        repeatButton.snp.makeConstraints { make in
            make.leading.equalTo(memoButton.snp.trailing).offset(15.adjust())
            make.centerY.equalTo(memoButton)
        }
        
        addTimeButton.snp.makeConstraints { make in
            make.leading.equalTo(repeatButton.snp.trailing).offset(15.adjust())
            make.centerY.equalTo(repeatButton)
        }
        
        extraTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(addTimeButton.snp.trailing).offset(5.adjust())
            make.centerY.equalTo(addTimeButton)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel)
            make.trailing.equalToSuperview().inset(25.adjust())
            make.bottom.equalTo(timerBadgeCollectionView.snp.top).inset(-20.adjust())
        }

        timerBadgeCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(65.adjust())
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
        view.backgroundColor = R.Color.alabaster
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
        backgroundColor = R.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([contentView, footerView])
        contentView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().priority(.high)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TimeSetProcessPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TimeSetProcessView {
        return TimeSetProcessView()
    }
    
    func updateUIView(_ uiView: TimeSetProcessView, context: Context) {
        // Nothing
    }
}

struct Previews_TimeSetProcessView: PreviewProvider {
    static var previews: some View {
        Group {
            TimeSetProcessPreview()
                .previewDevice("iPhone 6s")
            
            TimeSetProcessPreview()
                .previewDevice("iPhone 11")
        }
    }
}

#endif
