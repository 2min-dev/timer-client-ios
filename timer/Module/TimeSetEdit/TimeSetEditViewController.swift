//
//  TimeSetEditViewController.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import JSReorderableCollectionView

class TimeSetEditViewController: BaseHeaderViewController, View {
    // MARK: - constants
    private let MAX_TIMER_COUNT: Int = 10
    private let FOOTER_BUTTON_CANCEL: Int = 0
    private let FOOTER_BUTTON_NEXT: Int = 1
    
    // MARK: - view properties
    private var timeSetEditView: TimeSetEditView { return view as! TimeSetEditView }
    
    override var headerView: CommonHeader { return timeSetEditView.headerView }
    
    private var timerInputView: TimerInputView { return timeSetEditView.timerInputView }
    private var timerClearButton: UIButton { return timeSetEditView.timerInputView.timerClearButton }
    
    private var timeInfoView: UIView { return timeSetEditView.timeInfoView }
    private var allTimeLabel: UILabel { return timeSetEditView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetEditView.endOfTimeSetLabel }
    private var timerInputLabel: UILabel { return timeSetEditView.timeInputLabel }
    
    private var keyPadView: NumberKeyPad { return timeSetEditView.keyPadView }
    
    private var timeKeyView: TimeKeyPad { return timeSetEditView.timeKeyView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetEditView.timerBadgeCollectionView }
    
    private var timerOptionView: UIView { return timeSetEditView.timerOptionView }
    
    private var footerView: Footer { return timeSetEditView.footerView }
    
    // MARK: - properties
    private var isBadgeMoving: Bool = false
    private var timerOptionVisibleSubject: BehaviorRelay = BehaviorRelay(value: false)
    
    var coordinator: TimeSetEditViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetEditViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetEditView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
        timerBadgeCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - bind
    func bind(reactor: TimeSetEditViewReactor) {
        // MARK: action
        timerClearButton.rx.tap
            .map { Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        keyPadView.rx.keyPadTap
            .filter { $0 != .cancel }
            .map { [unowned self] in self.updateTime(key: $0) }
            .map { Reactor.Action.updateTime($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .filter { $0 == .cancel }
            .subscribe(onNext: { [weak self] _ in self?.showTimeSetInitWarningAlert() })
            .disposed(by: disposeBag)
        
        timeKeyView.rx.tap
            .map { [unowned self] in self.getBaseTime(from: $0) }
            .map { Reactor.Action.addTime(base: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        footerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.footerActionHandler(index: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Timer
        reactor.state
            .map { $0.endTime }
            .distinctUntilChanged()
            .bind(to: timerInputView.rx.timer)
            .disposed(by: disposeBag)
        
        // Time
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in self?.timerOptionVisibleSubject.accept(false) })
            .map { $0 > 0 ? String($0) : "" }
            .bind(to: timerInputLabel.rx.text)
            .disposed(by: disposeBag)
        
        // All time
        reactor.state
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { [weak self] in
                self?.getTimeSetInfoString(title: "time_set_all_time_title".localized,
                                           info: String(format: "time_set_all_time_format".localized, $0.0, $0.1, $0.2))
            }
            .bind(to: allTimeLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.allTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(30), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .map { Date().addingTimeInterval($0.0) }
            .map { [weak self] in
                self?.getTimeSetInfoString(title: "time_set_end_time_title".localized,
                                           info: getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)))
            }
            .bind(to: endOfTimeSetLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Time info view
        reactor.state
            .map { $0.time > 0 }
            .distinctUntilChanged()
            .bind(to: timeInfoView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Cancel key pad
//        reactor.state
//            .map { $0.timers.count <= 1 }
//            .distinctUntilChanged()
//            .bind(to: keyPadView.cancelButton.rx.isHidden)
//            .disposed(by: disposeBag)
        
        // Enable time key
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.endTime }, resultSelector: { ($0, $1) })
            .map { [unowned self] in self.getEnableTimeKey(from: $0.0, timer: $0.1) }
            .bind(to: timeKeyView.rx.enableKey)
            .disposed(by: disposeBag)
        
        // Next footer button
//        reactor.state
//            .map { $0.canTimeSetStart }
//            .distinctUntilChanged()
//            .bind(to: footerView.buttons[FOOTER_BUTTON_NEXT].rx.isEnabled)
//            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in _ = self?.coordinator.present(for: .home) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    override func handleHeaderAction(_ action: CommonHeader.Action) {
        switch action {
        case .back:
            showBackWarningAlert()
            
        case .delete:
            showTimeSetDeleteWarningAlert()
            
        default:
            break
        }
    }
    
    /// Convert number key pad input to time value
    private func updateTime(key: NumberKeyPad.Key) -> Int {
        guard var text = timerInputLabel.text else { return 0 }
        
        switch key {
        case .cancel:
            // Nothing to do
            break
        case .back:
            guard !text.isEmpty else { return 0 }
            text.removeLast()
        default:
            text.append(String(key.rawValue))
        }
        
        return Int(text) ?? 0
    }
    
    /// Get base time (second) from key of time key view
    private func getBaseTime(from key: TimeKeyPad.Key) -> TimeInterval {
        switch key {
        case .hour:
            return Constants.Time.hour
        case .minute:
            return Constants.Time.minute
        case .second:
            return 1
        }
    }
    
    /// Toggle timer option view visible state
    private func setVisibleOfTimerOptionView(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        if oldIndexPath == newIndexPath {
            timerOptionVisibleSubject.accept(!timerOptionVisibleSubject.value)
        } else {
            timerOptionVisibleSubject.accept(false)
        }
    }
    
    private func footerActionHandler(index: Int) {
        guard let reactor = reactor else { return }
        
        if index == FOOTER_BUTTON_CANCEL {
            // Cancel -> Pop view controller (alert)
            showBackWarningAlert()
        } else if index == FOOTER_BUTTON_NEXT {
            // Next -> Present time set save
            _ = coordinator.present(for: .timeSetSave(reactor.timeSetInfo))
        }
    }
    
    // MARK: - state method
    /// Get time set info's attributed string
    private func getTimeSetInfoString(title: String, info: String) -> NSAttributedString {
        let title = NSAttributedString(string: title,
                                       attributes: [.font: Constants.Font.Regular.withSize(12.adjust())])
        let time = NSAttributedString(string: info,
                                      attributes: [.font: Constants.Font.Bold.withSize(12.adjust())])
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(title)
        attributedString.append(time)
        return attributedString
    }
    
    /// Get enable time key from values of time & timer
    private func getEnableTimeKey(from time: Int, timer: TimeInterval) -> TimeKeyPad.Key {
        if timer + TimeInterval(time) * Constants.Time.minute > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
            return .second
        } else if timer + TimeInterval(time) * Constants.Time.hour > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
            return .minute
        } else {
            return .hour
        }
    }
    
    /// Show popup alert
    private func showAlert(message: String) {
        let alert = AlertBuilder(message: message).build()
        // Alert view controller dismiss after 1 seconds
        alert.rx.viewDidLoad
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak alert] in alert?.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        // Present alert view controller
        present(alert, animated: true)
    }
    
    // MARK: - private method
    /// Show end of time set edit warning alert
    private func showBackWarningAlert() {
        let alert = AlertBuilder(title: "alert_warning_time_set_edit_cancel_title".localized,
                                 message: "alert_warning_time_set_edit_cancel_description".localized)
            .addAction(title: "alert_button_cancel".localized, style: .cancel)
            .addAction(title: "alert_button_yes".localized, style: .destructive, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .build()
        // Present warning alert view controller
        present(alert, animated: true)
    }
    
    /// Show popup alert about warning to init time set
    private func showTimeSetInitWarningAlert() {
        guard let reactor = reactor else { return }
        
        let alert = AlertBuilder(title: "alert_warning_time_set_init_title".localized,
                                 message: "alert_warning_time_set_init_description".localized)
            .addAction(title: "alert_button_cancel".localized, style: .cancel)
            .addAction(title: "alert_button_yes".localized, style: .destructive, handler: { _ in
                reactor.action.onNext(.clearTimers)
            })
            .build()
        // Present warning alert view controller
        present(alert, animated: true)
    }
    
    /// Show  time set delete warning alert
    private func showTimeSetDeleteWarningAlert() {
        guard let reactor = reactor else { return }
        
        let alert = AlertBuilder(title: "alert_warning_time_set_delete_title".localized,
                                 message: "alert_warning_time_set_delete_description".localized)
            .addAction(title: "alert_button_cancel".localized, style: .cancel)
            .addAction(title: "alert_button_yes".localized, style: .destructive, handler: { _ in
                reactor.action.onNext(.deleteTimeSet)
            })
            .build()
        // Present warning alert view controller
        present(alert, animated: true)
    }
    
    // MARK: - selector
    @objc private func longPressHandler(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: timerBadgeCollectionView.superview)
        
        switch gesture.state {
        case .began:
            isBadgeMoving = true
            timerOptionVisibleSubject.accept(false)
            timerBadgeCollectionView.beginInteractiveWithLocation(location)
        case .changed:
            timerBadgeCollectionView.updateInteractiveWithLocation(location)
        default:
            isBadgeMoving = false
            timerBadgeCollectionView.finishInteractive()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
