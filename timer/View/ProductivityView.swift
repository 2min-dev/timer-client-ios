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
    
    enum TimerKey {
        case save
        case append
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
    
    private let dividerView: UIView = {
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
        let view = UIStackView(arrangedSubviews: [self.timerLabel, self.dividerView, self.timerInputLabel])
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
    
    private lazy var optionStackView: UIStackView = { [unowned self] in
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
    
    private lazy var contentStackView: UIStackView = { [unowned self] in
        let view = UIStackView(arrangedSubviews: [self.timerStackView, self.optionStackView, self.keyPadView, self.timeStackView])
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 10.adjust()
        return view
        }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setSubviewForAutoLayout(contentStackView)
        
        contentStackView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.center.equalTo(safeAreaLayoutGuide)
            } else {
                make.center.equalToSuperview()
            }
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        timerStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.height.equalTo(30.adjust())
        }
        
        timerInputLabel.snp.makeConstraints { make in
            make.height.equalTo(20.adjust())
        }
        
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(2.adjust())
        }
        
        optionStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        keyPadView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(320.adjust())
        }
        
        timeStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
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
