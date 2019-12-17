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
import RxDataSources
import JSReorderableCollectionView

class TimeSetEditViewController: BaseHeaderViewController, ViewControllable, View {
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
    
    private var timeKeyView: TimeKeyPad { return timeSetEditView.timeKeyPadView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetEditView.timerBadgeCollectionView }
    
    private var timerOptionView: TimerOptionView { return timeSetEditView.timerOptionView }
    
    private var cancelButton: FooterButton { return timeSetEditView.cancelButton }
    private var confirmButton: FooterButton { return timeSetEditView.confirmButton }
    
    // MARK: - properties
    private let canTimeSetStart: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let isTimerOptionVisible: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var isBadgeMoving: Bool = false
    
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
        
        // Set move item closure on timer badge datasource
        timerBadgeCollectionView._dataSource.moveItem = { [weak self] dataSource, sourceIndexPath, destinationIndexPath in
            let section = TimerBadgeSectionType.regular.rawValue
            guard let reactor = self?.reactor,
                sourceIndexPath.section == section && destinationIndexPath.section == section else { return }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            reactor.action.onNext(.moveTimer(at: sourceIndexPath.item, to: destinationIndexPath.item))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set navigation controller's pop gesture disable
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Set navigation controller's pop gesture enable
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - bind
    override func bind() {
        super.bind()

        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        canTimeSetStart
            .distinctUntilChanged()
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        isTimerOptionVisible
            .map { !$0 }
            .do(onNext: { [weak self] in self?.timeSetEditView.isEnabled = $0 })
            .do(onNext: { [weak self] in self?.timerBadgeCollectionView.isScrollEnabled = $0 })
            .bind(to: timerOptionView.rx.isHiddenWithAnimation)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetEditViewReactor) {
        // DI
        timerOptionView.reactor = reactor.timerOptionViewReactor
        bind(timerOption: timerOptionView)
        
        // MARK: action
        // Init badge
        rx.viewDidLayoutSubviews
            .takeUntil(rx.viewDidAppear)
            .withLatestFrom(reactor.state.map { $0.selectedIndex })
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.badgeScrollIfCan(at: $0, animated: false) })
            .disposed(by: disposeBag)
        
        timerClearButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        keyPadView.rx.keyPadTap
            .filter { $0 != .cancel }
            .compactMap { [weak self] in self?.updateTime(key: $0) }
            .map { Reactor.Action.updateTime($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .filter { $0 == .cancel }
            .subscribe(onNext: { [weak self] _ in self?.showTimeSetInitWarningAlert() })
            .disposed(by: disposeBag)
        
        timeKeyView.rx.tap
            .compactMap { [weak self] in self?.getBaseTime(from: $0) }
            .map { Reactor.Action.addTime(base: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let itemSelected = timerBadgeCollectionView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .withLatestFrom(reactor.state.map { $0.selectedIndex }, resultSelector: { ($0, $1) })
            .share(replay: 1)
        
        itemSelected
            .compactMap { [weak self] in self?.selectBadge(at: $0.0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        itemSelected
            .filter { $0.0.section == TimerBadgeSectionType.regular.rawValue }
            .filter { $0.0.item == $0.1 }
            .map { [weak self] _ in !(self?.isTimerOptionVisible.value ?? true) }
            .bind(to: isTimerOptionVisible)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.showBackWarningAlert() })
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .map { Reactor.Action.saveTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Can time set start
        reactor.state
            .map { $0.allTime > 0 }
            .distinctUntilChanged()
            .bind(to: canTimeSetStart)
            .disposed(by: disposeBag)
        
        // Timer end time
        reactor.state
            .map { $0.endTime }
            .distinctUntilChanged()
            .bind(to: timerInputView.rx.timer)
            .disposed(by: disposeBag)
        
        // Current inputed time
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { $0 > 0 ? "\("productivity_time_input_prefix_title".localized)\($0)" : "" }
            .bind(to: timerInputLabel.rx.text)
            .disposed(by: disposeBag)
        
        // All time
        reactor.state
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_all_time_title_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: allTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.allTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(30), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .map { String(format: "time_set_end_time_title_format".localized, $0) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time info view
        reactor.state
            .map { $0.time > 0 || $0.allTime == 0 }
            .distinctUntilChanged()
            .bind(to: timeInfoView.rx.isHiddenWithAnimation)
            .disposed(by: disposeBag)
        
        // Time key
        reactor.state
            .map { $0.time == 0 && $0.allTime == 0 }
            .distinctUntilChanged()
            .bind(to: timeKeyView.rx.isHiddenWithAnimation, keyPadView.cancelButton.rx.isHiddenWithAnimation)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.endTime }, resultSelector: { ($0, $1) })
            .compactMap { [weak self] in self?.getEnableTimeKey(from: $0.0, endTime: $0.1) }
            .bind(to: timeKeyView.rx.enableKey)
            .disposed(by: disposeBag)
        
        // Timer badge
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: timerBadgeCollectionView.rx.items(dataSource: timerBadgeCollectionView._dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in self?.isTimerOptionVisible.accept(false) })
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.badgeScrollIfCan(at: $0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldSave }
            .subscribe(onNext: { [weak self] _ in _ = self?.coordinator.present(for: .timeSetSave(reactor.timeSetItem)) })
            .disposed(by: disposeBag)
        
        // Scroll to selected badge when timer option view visible
        isTimerOptionVisible
            .filter { $0 }
            .withLatestFrom(reactor.state.map { $0.selectedIndex })
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.badgeScrollIfCan(at: $0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in _ = self?.coordinator.present(for: .home) })
            .disposed(by: disposeBag)
    }
    
    private func bind(timerOption view: TimerOptionView) {
        guard let reactor = reactor else { return }
        
        view.rx.tapApplyAll
            .do(onNext: { Toast(content: String(format: "toast_alarm_all_apply_title".localized, $0.title)).show(animated: true, withDuration: 3) })
            .map { Reactor.Action.alarmApplyAll($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        view.rx.tapDelete
            .do(onNext: { [weak self] in self?.isTimerOptionVisible.accept(false) })
            .map { Reactor.Action.deleteTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - action method
    /// - warning: Don't call `super.handleHeaderAction()` to override default action
    func handleHeaderAction(_ action: CommonHeader.Action) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
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
        guard let text = timerInputLabel.text else { return 0 }
        
        let prefix = "productivity_time_input_prefix_title".localized
        let range = Range(uncheckedBounds: (text.range(of: prefix)?.upperBound ?? text.startIndex, text.endIndex))
        var time = String(text[range])
        
        switch key {
        case .cancel:
            break
            
        case .back:
            guard !time.isEmpty else { return 0 }
            time.removeLast()
            
        default:
            time.append(String(key.rawValue))
        }
        
        return Int(time) ?? 0
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
    
    /// Convert badge select event to reactor action
    private func selectBadge(at indexPath: IndexPath) -> TimeSetEditViewReactor.Action? {
        guard let reactor = reactor else { return nil }
        
        let cellType = reactor.currentState.sections[indexPath.section].items[indexPath.item]
        switch cellType {
        case .regular(_):
            return .selectTimer(at: indexPath.item)
            
        case let .extra(type):
            switch type {
            case .add:
                return .addTimer
                
            case .repeat:
                return .toggleRepeat
            }
        }
    }
    
    // MARK: - state method
    /// Get enable time key from values of time & timer
    private func getEnableTimeKey(from time: Int, endTime: TimeInterval) -> TimeKeyPad.Key {
        if endTime + (TimeInterval(time) * Constants.Time.minute) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
            return .second
        } else if endTime + (TimeInterval(time) * Constants.Time.hour) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
            return .minute
        } else {
            return .hour
        }
    }
    
    /// Scroll timer badge view if badge isn't moving
    private func badgeScrollIfCan(at indexPath: IndexPath, animated: Bool = true) {
        guard !isBadgeMoving else { return }
        timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: animated)
    }
    
    // MARK: - private method
    /// Show end of time set edit warning alert
    private func showBackWarningAlert() {
        let alert = AlertBuilder(title: "alert_warning_time_set_edit_cancel_title".localized,
                                 message: "alert_warning_time_set_edit_cancel_description".localized)
            .addAction(title: "alert_button_cancel".localized, style: .cancel)
            .addAction(title: "alert_button_yes".localized, style: .destructive, handler: { _ in
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.coordinator.present(for: .dismiss(animated: true))
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
            .addAction(title: "alert_button_init".localized, style: .destructive, handler: { _ in
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
            .addAction(title: "alert_button_delete".localized, style: .destructive, handler: { _ in
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
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            isTimerOptionVisible.accept(false)
            isBadgeMoving = true
            
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
