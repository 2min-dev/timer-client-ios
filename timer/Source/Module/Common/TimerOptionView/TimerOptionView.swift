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
import ReactorKit

class TimerOptionView: UIView, View {
    enum AlarmType: Int {
        case `default` = 0
        case vibrate
        case silence
        
        var button: UIButton {
            let button = UIButton()
            button.tag = rawValue
            button.titleLabel?.font = Constants.Font.Regular.withSize(15.adjust())
            button.setTitleColor(R.Color.codGray, for: .normal)
            
            switch self {
            case .default:
                button.setTitle("timer_option_alarm_default_title".localized, for: .normal)
                
            case .vibrate:
                button.setTitle("timer_option_alarm_vibrate_title".localized, for: .normal)
                
            case .silence:
                button.setTitle("timer_option_alarm_silence_title".localized, for: .normal)
            }
            
            return button
        }
        
        var alarm: Alarm {
            switch self {
            case .default:
                return .default
                
            case .vibrate:
                return .vibrate
                
            case .silence:
                return .silence
            }
        }
    }
    
    // MARK: - constants
    private static let MAX_COMMENT_LENGTH: Int = 100
    
    // MARK: - view properties
    lazy var commentTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = R.Color.clear
        view.textContainerInset = UIEdgeInsets(top: 5.adjust(), left: 0, bottom: 0, right: 0) // Vertical padding
        view.textContainer.lineFragmentPadding = 5.adjust() // Horizontal padding
        
        // Disable auto correction (keyboard)
        view.autocorrectionType = .no
        view.inputAccessoryView = keyboardAccessoryView
        
        // Set line height of text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.adjust()
        
        view.typingAttributes = [.font: Constants.Font.Regular.withSize(15.adjust()),
                                 .foregroundColor: R.Color.codGray,
                                 .kern: -0.45,
                                 .paragraphStyle: paragraphStyle]
        return view
    }()
    
    let commentLengthLabel: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = R.Color.codGray
        view.textAlignment = .right
        return view
    }()
    
    let commentHintLabel: UILabel = {
        let view = UILabel()
        
        let string = "timer_option_comment_hint_title".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: R.Color.silver,
            .kern: -0.45
        ]
        
        view.attributedText = NSAttributedString(string: string, attributes: attributes)
        return view
    }()
    
    let commentExcessLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = R.Color.carnation
        view.text = "timer_option_comment_excess_title".localized
        return view
    }()
    
    private lazy var commentInputView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([commentTextView, commentLengthLabel, commentHintLabel, commentExcessLabel])
        commentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.adjust())
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalToSuperview().inset(20.adjust())
            make.bottom.equalTo(commentLengthLabel.snp.top).inset(-8.adjust())
        }
        
        commentLengthLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15.adjust())
            make.bottom.equalToSuperview().inset(11.adjust())
        }
        
        commentHintLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTextView).offset(commentTextView.textContainerInset.top)
            make.leading.equalTo(commentTextView).offset(commentTextView.textContainer.lineFragmentPadding)
        }
        
        commentExcessLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15.adjust())
            make.trailing.equalTo(commentLengthLabel.snp.leading).inset(10.adjust())
            make.centerY.equalTo(commentLengthLabel)
        }
        
        return view
    }()
    
    private let alarmIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.Icon.icSound
        return view
    }()
    
    private lazy var alarmButtonsStackView: UIStackView = {
        let buttons: [AlarmType] = [.silence, .vibrate, .default]
        let view = UIStackView(arrangedSubviews: buttons.map { $0.button })
        view.alignment = .center
        view.spacing = 10.adjust()
        return view
    }()
    
    private let alarmIndicatorView: UIView = {
        let view = UIView()
        view.bounds.size.height = 6.adjust()
        view.backgroundColor = R.Color.carnation
        return view
    }()
    
    let alarmApplyAllButton: UIButton = {
        let view = UIButton()
        let string = "timer_option_alarm_all_apply".localized
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: R.Color.codGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: Constants.Font.Regular.withSize(15.adjust())
        ]
        view.setAttributedTitle(NSAttributedString(string: string, attributes: attributes), for: .normal)
        return view
    }()
    
    private lazy var alarmSettingView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = R.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([divider, alarmIconImageView, alarmButtonsStackView, alarmApplyAllButton])
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(10.5.adjust())
            make.trailing.equalToSuperview().inset(9.5.adjust())
            make.height.equalTo(1.adjust())
        }
        
        alarmIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
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
            make.trailing.equalToSuperview().inset(15.adjust())
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
        view.image = R.Icon.icTimer
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = R.Color.codGray
        return view
    }()
    
    let deleteButton: UIButton = {
        let view = UIButton()
        view.setImage(R.Icon.icBtnDelete, for: .normal)
        return view
    }()
    
    private lazy var timerInfoView: UIView = {
        let view = UIView()
        
        let divider = UIView()
        divider.backgroundColor = R.Color.gallery
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([divider, timerIconImageView, titleLabel, deleteButton])
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(10.5.adjust())
            make.trailing.equalToSuperview().inset(9.5.adjust())
            make.height.equalTo(1.adjust())
        }
        
        timerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10.adjust())
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
            make.trailing.equalToSuperview().inset(22.adjust())
            make.centerY.equalToSuperview()
            make.height.equalTo(36.adjust())
            make.width.equalTo(deleteButton.snp.height)
        }
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [commentInputView, alarmSettingView, timerInfoView])
        view.axis = .vertical
        
        // Set constraint of subviews
        alarmSettingView.snp.makeConstraints { make in
            make.height.equalTo(66.adjust())
        }
        
        timerInfoView.snp.makeConstraints { make in
            make.height.equalTo(66.adjust())
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
        layer.fillColor = R.Color.white.cgColor
        layer.strokeColor = R.Color.codGray.cgColor
        layer.lineWidth = 1
        layer.shadow(alpha: 0.16, offset: CGSize(width: 0, height: 3.adjust()), blur: 6.adjust())
        return layer
    }()
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300.adjust(), height: 379.adjust())
    }
    
    var isExceeded: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.white
        
        // Set constraint of subviews
        addAutolayoutSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        layer.insertSublayer(borderLayer, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func draw(_ rect: CGRect) {
        borderLayer.path = drawBorderLayer(frame: bounds, corner: 15.adjust()).cgPath
    }
    
    // MARK: - bind
    private func bind() {
        Observable.merge(
            alarmButtonsStackView.arrangedSubviews
                .compactMap { $0 as? UIButton }
                .map { button -> Observable<AlarmType> in button.rx.tap.compactMap { AlarmType(rawValue: button.tag) } })
            .subscribe(onNext: { [weak self] in self?.setAlarmType($0) })
            .disposed(by: disposeBag)
        
        commentTextView.rx.text
            .orEmpty
            .map { !$0.isEmpty }
            .bind(to: commentHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        commentTextView.rx.text
            .orEmpty
            .filter { $0.lengthOfBytes(using: .euc_kr) > Self.MAX_COMMENT_LENGTH }
            .do(onNext: { [weak self] _ in self?.isExceeded.accept(true) })
            .map { String($0.dropLast()) }
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Comment length
        Observable.combineLatest(
            commentTextView.rx.text
                .orEmpty
                .map { $0.lengthOfBytes(using: .euc_kr) }
                .distinctUntilChanged(),
            isExceeded.distinctUntilChanged())
            .compactMap { [weak self] in self?.getCommentLengthAttributedString(length: $0, isExceeded: $1) }
            .bind(to: commentLengthLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Exceeded comment
        isExceeded
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: commentExcessLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        isExceeded
            .filter { $0 }
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .map { !$0 }
            .bind(to: isExceeded)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: TimerOptionViewReactor) {
        // Bind view reactive stream
        bind()
        
        // MARK: action
        commentTextView.rx.text
            .orEmpty
            .compactMap { Reactor.Action.updateComment($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(
            alarmButtonsStackView.arrangedSubviews
                .compactMap { $0 as? UIButton }
                .map { button in button.rx.tap.compactMap { AlarmType(rawValue: button.tag) } })
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { .updateAlarm($0.alarm) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(
            alarmApplyAllButton.rx.tap.asObservable(),
            deleteButton.rx.tap.asObservable())
            .subscribe(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        let timerIndex = reactor.state
            .map { $0.index + 1 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        timerIndex
            .map { String(format: "timer_option_title_format".localized, $0) }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Comment
        reactor.state
            .map { $0.comment }
            .distinctUntilChanged()
            .filter { [weak self] in self?.commentTextView.text != $0 }
            .do(onNext: { [weak self] _ in self?.isExceeded.accept(false) })
            .do(onNext: { [weak self] _ in self?.commentTextView.contentOffset.y = 0 })
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Alarm
        reactor.state
            .map { $0.alarm }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .silence:
                    self?.setAlarmType(.silence)
                
                case .vibrate:
                    self?.setAlarmType(.vibrate)
                    
                case .default:
                    self?.setAlarmType(.default)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - state method
    /// Get comment length attributed string
    private func getCommentLengthAttributedString(length: Int, isExceeded: Bool) -> NSAttributedString {
        let lengthString = String(format: "timer_option_comment_bytes_format".localized, length, Self.MAX_COMMENT_LENGTH)
        let attributedString = NSMutableAttributedString(string: lengthString)
        
        if isExceeded {
            // Highlight length text
            let range = NSString(string: lengthString).range(of: String(length))
            attributedString.addAttribute(.foregroundColor, value: R.Color.carnation, range: range)
        }
        
        return attributedString
    }
    
    // MARK: - private method
    /// Set timer alarm type
    private func setAlarmType(_ type: AlarmType) {
        guard let view = alarmButtonsStackView.arrangedSubviews.first(where: { $0.tag == type.rawValue }) else { return }
        
        // Remake constraints of indicator view to fit selected alarm view
        alarmIndicatorView.snp.remakeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view).inset(4.adjust())
            make.height.equalTo(6.adjust())
        }
    }
    
    /// Draw timer option view border layer
    private func drawBorderLayer(frame: CGRect, corner radius: CGFloat) -> UIBezierPath {
        let tailSize = CGSize(width: 24.adjust(), height: 14.adjust())
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
        commentTextView.endEditing(true)
    }
}

extension Reactive where Base: TimerOptionView {
    // MARK: - binder
    var timer: Binder<(TimerItem, Int)> {
        return Binder(base.self) { _, item in
            self.base.reactor?.action.onNext(.updateTimer(item.0, at: item.1))
        }
    }
    
    // MARK: - control event
    var tapDelete: ControlEvent<Void> {
        return ControlEvent(events: base.deleteButton.rx.tap)
    }
    
    var tapApplyAll: ControlEvent<Alarm> {
        return ControlEvent(events: base.alarmApplyAllButton.rx.tap
            .withLatestFrom(base.reactor?.state.map { $0.alarm } ?? .empty()))
    }
}
