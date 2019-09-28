//
//  TimerOptionView.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerOptionView: UIView {
    enum AlarmType: Int {
        case silence = 0
        case vibrate
        case `default`
        
        var button: UIButton {
            let button = UIButton()
            button.tag = rawValue
            button.titleLabel?.font = Constants.Font.Regular.withSize(10.adjust())
            button.setTitleColor(Constants.Color.codGray, for: .normal)
            
            switch self {
            case .silence:
                button.setTitle("timer_option_alarm_silence_title".localized, for: .normal)
                
            case .vibrate:
                button.setTitle("timer_option_alarm_vibrate_title".localized, for: .normal)
                
            case .default:
                button.setTitle("timer_option_alarm_default_title".localized, for: .normal)
            }
            
            return button
        }
    }
    
    // MARK: - view properties
    lazy var commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Constants.Color.white
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        view.textContainerInset = UIEdgeInsets(top: 5.adjust(), left: 0, bottom: 0, right: 0) // Vertical padding
        view.textContainer.lineFragmentPadding = 5.adjust() // Horizontal padding
        
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        view.inputAccessoryView = keyboardAccessoryView
        return view
    }()
    
    let commentLengthLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(10.adjust())
        view.textColor = Constants.Color.codGray
        view.textAlignment = .right
        return view
    }()
    
    let commentHintLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.silver
        view.text = "timer_comment_hint".localized
        return view
    }()
    
    private lazy var commentInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([commentTextView, commentLengthLabel, commentHintLabel])
        commentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5.adjust())
            make.leading.equalToSuperview().inset(5.adjust())
            make.trailing.equalToSuperview().inset(5.adjust())
            make.bottom.equalTo(commentLengthLabel.snp.top).inset(-8.adjust())
        }
        
        commentLengthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(17.adjust())
            make.trailing.equalToSuperview().inset(17.adjust())
            make.bottom.equalToSuperview().inset(16.adjust())
        }
        
        commentHintLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTextView).offset(commentTextView.textContainerInset.top)
            make.leading.equalTo(commentTextView).offset(commentTextView.textContainer.lineFragmentPadding)
        }
        
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon_sound")
        return view
    }()
    
    private lazy var alarmButtonsStackView: UIStackView = {
        let buttons: [AlarmType] = [.silence, .vibrate, .default]
        let view = UIStackView(arrangedSubviews: buttons.map { $0.button })
        view.spacing = 10.adjust()
        return view
    }()
    
    private let alarmIndicatorView: UIView = {
        let view = UIView()
        view.bounds.size.height = 6.adjust()
        view.backgroundColor = Constants.Color.carnation
        return view
    }()
    
    let alarmApplyAllButton: UIButton = {
        let view = UIButton()
        let string = "timer_option_alarm_all_apply".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.Color.codGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: Constants.Font.Regular.withSize(10.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        return view
    }()
    
    private lazy var alarmSettingView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([divider, alarmIconImageView, alarmButtonsStackView, alarmApplyAllButton])
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(2.adjust())
            make.trailing.equalToSuperview().inset(2.adjust())
            make.height.equalTo(1.adjust())
        }
        
        alarmIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5.adjust())
            make.centerY.equalToSuperview()
            make.height.equalTo(36.adjust())
            make.width.equalTo(alarmIconImageView.snp.height)
        }
        
        alarmButtonsStackView.snp.makeConstraints { make in
            make.leading.equalTo(alarmIconImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        alarmApplyAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(10.adjust())
            make.bottom.equalToSuperview()
        }
        
        // Add alarm select indicator view
        view.insertSubview(alarmIndicatorView, at: 0)
        alarmIndicatorView.frame.origin.y = 32.adjust()
        
        return view
    }()
    
    private let timerIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(named: "icon_timer")
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
        
    let deleteButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_delete_mini"), for: .normal)
        return view
    }()
    
    private lazy var timerInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([divider, timerIconImageView, titleLabel, deleteButton])
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(2.adjust())
            make.trailing.equalToSuperview().inset(2.adjust())
            make.height.equalTo(1.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5.adjust())
            make.centerY.equalToSuperview()
            make.height.equalTo(36.adjust())
            make.width.equalTo(timerIconImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(timerIconImageView.snp.trailing).offset(5.adjust())
            make.trailing.equalTo(deleteButton.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10.adjust())
            make.centerY.equalToSuperview()
            make.height.equalTo(24.adjust())
            make.width.equalTo(deleteButton.snp.height)
        }
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentInputView, alarmSettingView, timerInfoView])
        view.axis = .vertical
        
        // Set constraint of subviews
        alarmSettingView.snp.makeConstraints { make in
            make.height.equalTo(60.adjust())
        }
        
        timerInfoView.snp.makeConstraints { make in
            make.height.equalTo(60.adjust())
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
    
    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Constants.Color.white.cgColor
        layer.strokeColor = Constants.Color.codGray.cgColor
        layer.lineWidth = 1
        layer.shadow(alpha: 0.16, offset: CGSize(width: 0, height: 3.adjust()), blur: 6.adjust())
        return layer
    }()
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250.adjust(), height: 300.adjust())
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        layer.insertSublayer(borderLayer, at: 0)
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        borderLayer.path = drawBorderLayer(frame: bounds, corner: 5.adjust()).cgPath
    }
    
    // MARK: - bind
    private func bind() {
        Observable.merge(
            alarmButtonsStackView.arrangedSubviews
                .compactMap { $0 as? UIButton }
                .map { button -> Observable<AlarmType> in button.rx.tap.compactMap { AlarmType(rawValue: button.tag) } }
            )
            .subscribe(onNext: { [weak self] in self?.setAlarmType($0) })
            .disposed(by: disposeBag)
        
        commentTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: commentHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    /// Set timer alarm type
    private func setAlarmType(_ type: AlarmType) {
        guard let view = alarmButtonsStackView.arrangedSubviews.first(where: { $0.tag == type.rawValue }) else { return }
        // Convert button frame to coordinate space of alarm buttons stack view
        let origin = alarmButtonsStackView.convert(view.frame.origin, to: alarmSettingView)
        
        // Set indicator view frame
        alarmIndicatorView.frame.origin.x = origin.x
        alarmIndicatorView.frame.size.width = view.bounds.width
    }
    
    /// Draw timer option view border layer
    private func drawBorderLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
        let tailSize = CGSize(width: 13.adjust(), height: 8.adjust())
        // Initial point of border path
        let initialPoint = CGPoint(x: radius, y: frame.height)
        // Tail points
        let tailPoints: [CGPoint] = [
            CGPoint(x: (frame.width - tailSize.width) * 0.5, y: frame.height + 0.5),
            CGPoint(x: frame.width * 0.5, y: frame.height + tailSize.height + 0.5),
            CGPoint(x: (frame.width + tailSize.width) * 0.5, y: frame.height + 0.5)
        ]
        // Round corner points
        let cornerPoints: [(CGPoint, CGPoint?, CGPoint?)] = [
            // Right-Bottom
            (CGPoint(x: frame.width - radius, y: frame.height), nil, nil),
            (CGPoint(x: frame.width, y: frame.height - radius),
             CGPoint(x: frame.width - radius * 0.5, y: frame.height),
             CGPoint(x: frame.width, y: frame.height - radius * 0.5)),
            // Right-Top
            (CGPoint(x: frame.width, y: radius), nil, nil),
            (CGPoint(x: frame.width - radius, y: 0),
             CGPoint(x: frame.width, y: radius * 0.5),
             CGPoint(x: frame.width - radius * 0.5, y: 0)),
            // Left-Top
            (CGPoint(x: radius, y: 0), nil, nil),
            (CGPoint(x: 0, y: radius),
             CGPoint(x: radius * 0.5, y: 0),
             CGPoint(x: 0, y: radius * 0.5)),
            // Left-Bottom
            (CGPoint(x: 0, y: frame.height - radius), nil, nil),
            (CGPoint(x: radius, y: frame.height),
             CGPoint(x: 0, y: frame.height - radius * 0.5),
             CGPoint(x: radius * 0.5, y: frame.height))
        ]
        
        // Draw path
        let path = UIBezierPath()
        path.move(to: initialPoint)
        
        tailPoints.forEach { path.addLine(to: $0) }
        cornerPoints.forEach {
            if let controlPoint1 = $0.1, let controlPoint2 = $0.2 {
                path.addCurve(to: $0.0, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            } else {
                path.addLine(to: $0.0)
            }
        }
        
        return path
    }
    
    // MARK: - selector
    @objc private func touchCommentDone(_ sender: UIBarButtonItem) {
        Logger.debug(sender)
        commentTextView.endEditing(true)
    }
}
