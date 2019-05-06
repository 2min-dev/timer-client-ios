//
//  ProductivityView.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProductivityView: UIView {
    enum TimeKey {
        case hour
        case minute
        case second
    }
    
    enum TimerButtonType {
        case save
        case add
        case start
    }
    
    // MARK: - view properties
    let timerLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.NanumSquareRoundEB.withSize(25.adjust())
        view.text = ""
        view.textAlignment = .center
        return view
    }()
    
    private let timerDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let timerInputLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.NanumSquareRoundB.withSize(20.adjust())
        view.text = ""
        view.textAlignment = .center
        return view
    }()
    
    private lazy var timerStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.timerLabel, self.timerDividerView, self.timerInputLabel])
        view.axis = .vertical
        view.spacing = 10.adjust()
        return view
    }()
    
    let loopCheckBox: CheckBox = {
        let view = CheckBox()
        let string = "app_check_box_loop_title".localized
        view.setAttributedTitle(NSAttributedString(string: string, attributes: [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(15.adjust())
            ]))
        return view
    }()
    
    let vibrationAlertCheckBox: CheckBox = {
        let view = CheckBox()
        let string = "app_check_box_vibration_alert_title".localized
        view.setAttributedTitle(NSAttributedString(string: string, attributes: [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(15.adjust())
            ]))
        return view
    }()
    
    lazy var optionStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.loopCheckBox, self.vibrationAlertCheckBox])
        view.axis = .horizontal
        view.distribution = .fillProportionally
        return view
    }()
    
    let keyPadView: KeyPadView = {
        let view = KeyPadView()
        view.fontSize = 30.adjust()
        return view
    }()
    
    let hourButton: UIButton = {
        let view = UIButton()
        let string = "app_button_hour_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let minuteButton: UIButton = {
        let view = UIButton()
        let string = "app_button_minute_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let secondButton: UIButton = {
        let view = UIButton()
        let string = "app_button_second_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(25.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    private lazy var timeStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.hourButton, self.minuteButton, self.secondButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private let alertLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.NanumSquareRoundEB.withSize(15.adjust())
        view.text = "app_button_alert_default".localized
        return view
    }()
    
    let changeButton: UIButton = {
        let view = UIButton()
        let string = "app_button_alert_change_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(15.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    private lazy var alertStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.alertLabel, self.changeButton])
        view.axis = .horizontal
        view.distribution = .equalCentering
        return view
    }()
    
    let saveButton: UIButton = {
        let view = UIButton()
        let string = "app_button_timer_save_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(30.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let addButton: UIButton = {
        let view = UIButton()
        let string = "app_button_timer_add_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(30.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    let startButton: UIButton = {
        let view = UIButton()
        let string = "app_button_timer_start_title".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.black,
            .font: Constants.Font.NanumSquareRoundEB.withSize(30.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        
        attributes[.foregroundColor] = Constants.Color.gray
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .highlighted)
        return view
    }()
    
    private lazy var timerButtonStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.saveButton, self.addButton, self.startButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private let footerDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var footerView: UIView = { [unowned self] in
        let view = UIView()
        view.setSubviewsForAutoLayout([self.alertStackView, self.footerDividerView, self.timerButtonStackView])
        return view
    }()
    
    private lazy var contentView: UIView = { [unowned self] in
        let view = UIView()
        view.setSubviewsForAutoLayout([self.timerStackView, self.optionStackView, self.keyPadView, self.timeStackView])
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setSubviewsForAutoLayout([contentView, footerView])
        
        contentView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.center.equalTo(safeAreaLayoutGuide)
            } else {
                make.center.equalToSuperview()
            }
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        timerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.height.equalTo(30.adjust())
        }
        
        timerDividerView.snp.makeConstraints { make in
            make.height.equalTo(2.adjust())
        }
        
        timerInputLabel.snp.makeConstraints { make in
            make.height.equalTo(20.adjust())
        }
        
        optionStackView.snp.makeConstraints { make in
            make.top.equalTo(timerStackView.snp.bottom).offset(5.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(30.adjust())
        }
        
        keyPadView.snp.makeConstraints { make in
            make.top.equalTo(optionStackView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(320.adjust())
        }
        
        timeStackView.snp.makeConstraints { make in
            make.top.equalTo(keyPadView.snp.bottom).offset(10.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30.adjust())
        }

        footerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(100.adjust())
        }

        alertStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(timerDividerView.snp.width).multipliedBy(0.9)
            make.height.equalTo(30.adjust())
        }

        footerDividerView.snp.makeConstraints { make in
            make.top.equalTo(alertStackView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(timerDividerView.snp.width)
            make.height.equalTo(2.adjust())
        }

        timerButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(footerDividerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - extension
extension Reactive where Base: ProductivityView {
    var timeKeyTap: ControlEvent<Base.TimeKey> {
        let hourObservable = base.hourButton.rx.tap.map { Base.TimeKey.hour }
        let minuteObservable = base.minuteButton.rx.tap.map { Base.TimeKey.minute }
        let secondObservable = base.secondButton.rx.tap.map { Base.TimeKey.second }
        
        let source = Observable.merge(hourObservable, minuteObservable, secondObservable)
        return ControlEvent(events: source)
    }
}
