//
//  TimeSetProcessViewController.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class TimeSetProcessViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var timeSetProcessView: TimeSetProcessView { view as! TimeSetProcessView }
    
    private var titleLabel: UILabel { timeSetProcessView.titleLabel }
    private var stateLabel: UILabel { timeSetProcessView.stateLabel }
    private var stateHighlightView: UIView { timeSetProcessView.stateHighlightView }
    private var timeLabel: UILabel { timeSetProcessView.timeLabel }
    
    private var memoButton: RoundButton { timeSetProcessView.memoButton }
    private var repeatButton: RoundButton { timeSetProcessView.repeatButton }
    private var addTimeButton: RoundButton { timeSetProcessView.addTimeButton }
    
    private var extraTimeLabel: UILabel { timeSetProcessView.extraTimeLabel }
    
    private var allTimeLabel: UILabel { timeSetProcessView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { timeSetProcessView.endOfTimeSetLabel }
    private var alarmLabel: UILabel { timeSetProcessView.alarmLabel }
    private var commentTextView: UITextView { timeSetProcessView.commentTextView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { timeSetProcessView.timerBadgeCollectionView }
    
    private var startButton: FooterButton { timeSetProcessView.startButton }
    private var stopButton: FooterButton { timeSetProcessView.stopButton }
    private var quitButton: FooterButton { timeSetProcessView.quitButton }
    private var pauseButton: FooterButton { timeSetProcessView.pauseButton }
    
    private var footerView: Footer { timeSetProcessView.footerView }
    
    private var timeSetPopup: TimeSetPopup? {
        didSet { oldValue?.removeFromSuperview() }
    }
    private var bubbleAlert: BubbleAlert? {
        didSet {
            oldValue?.removeFromSuperview()
            timerBadgeCollectionView.isScrollEnabled = bubbleAlert == nil
        }
    }
    
    // MARK: - properties
    var coordinator: TimeSetProcessViewCoordinator
    
    // Dispose bags
    private var popupDisposeBag = DisposeBag()
    private var alertDisposeBag = DisposeBag()
    
    // MARK: - constructor
    init(coordinator: TimeSetProcessViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetProcessView()
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
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func bind() {
        super.bind()
        
        stateLabel.rx.observe(NSAttributedString.self, "attributedText")
            .compactMap { $0?.string.isEmpty ?? true }
            .bind(to: stateHighlightView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetProcessViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Init badge
        rx.viewDidLayoutSubviews
            .takeUntil(rx.viewDidAppear)
            .withLatestFrom(reactor.state.map { $0.selectedIndex })
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: false) })
            .disposed(by: disposeBag)
        
        memoButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .subscribe(onNext: { [weak self] in
                guard let viewController = self?.coordinator.present(for: .timeSetMemo(reactor.timeSet.history), animated: true) as? TimeSetMemoViewController else { return }
                self?.bind(memo: viewController)
            })
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { Reactor.Action.toggleRepeat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addTimeButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { Reactor.Action.addExtraTime(TimeInterval(Constants.Time.minute)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .filter { $0.section == TimerBadgeSectionType.regular.rawValue }
            .subscribe(onNext: { [weak self] in self?.badgeSelect(at: $0) })
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .map { Reactor.Action.startTimeSet(at: nil) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge(stopButton.rx.tap.asObservable(),
                         quitButton.rx.tap.asObservable())
            .map { Reactor.Action.stopTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pauseButton.rx.tap
            .map { Reactor.Action.pauseTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Repeat
        reactor.state
            .map { $0.isRepeat }
            .distinctUntilChanged()
            .bind(to: repeatButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Extra time
        reactor.state
            .map { $0.extraTime == 0 }
            .distinctUntilChanged()
            .bind(to: extraTimeLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.extraTime }
            .distinctUntilChanged()
            .map { Int($0 / Constants.Time.minute) }
            .map { String(format: "time_set_process_extra_time_format".localized, $0) }
            .bind(to: extraTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // All time
        reactor.state
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: allTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.remainedTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(30), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .observeOn(MainScheduler.instance)
            .takeUntil( // Take until time set is running
                reactor.state
                    .map { $0.timeSetState }
                    .distinctUntilChanged()
                    .filter { $0 == .end })
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Timer
        let timer = reactor.state
            .map { $0.timer }
            .distinctUntilChanged { $0 == $1 }
            .share(replay: 1)
            
        // Alarm
        timer.map { $0.alarm.title }
            .bind(to: alarmLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Comment
        timer.map { $0.comment }
            .do(onNext: { [weak self] _ in self?.commentTextView.contentOffset.y = 0 })
            .bind(to: commentTextView.rx.text)
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
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.scrollBadgeIfCan(at: $0) })
            .disposed(by: disposeBag)

        // Timer end popup
        reactor.state
            .map { $0.timerState }
            .distinctUntilChanged()
            .filter { $0 == .end }
            .withLatestFrom(reactor.state.map { ($0.selectedIndex,
                                                 $0.sectionDataSource.regulars.count,
                                                 $0.isRepeat,
                                                 reactor.timeSet.history.repeatCount) })
            .subscribe(onNext: { [weak self] in self?.showTimeSetPopup(index: $0, count: $1, isRepeat: $2, repeatCount: $3) })
            .disposed(by: disposeBag)
        
        // Time set state
        Observable.combineLatest(
            reactor.state.map { $0.countdown }.distinctUntilChanged(),
            reactor.state.map { $0.countdownState }.distinctUntilChanged())
            .compactMap { [weak self] in self?.getTimeSetStateByCountdown($0, state: $1) }
            .bind(to: stateLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timeSetState }
            .distinctUntilChanged()
            .map { ($0, reactor.timeSet.history) }
            .compactMap { [weak self] in self?.getTimeSetState($0, history: $1) }
            .bind(to: stateLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timeSetState }
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map { $0.canTimeSetSave }) { ($0, $1) }
            .map { ($0.0, reactor.timeSet.history, $0.1) }
            .subscribe(onNext: { [weak self] in self?.updateLayoutByTimeSetState($0, history: $1, canSave: $2) })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.countdownState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateLayoutByCountdownState($0) })
            .disposed(by: disposeBag)
        
        // Dismiss
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
    }
    
    func bind(memo viewController: TimeSetMemoViewController) {
        guard let reactor = reactor else { return }
        
        // Close
        viewController.rx.close
            .withLatestFrom(reactor.state.map { $0.timeSetState })
            .filter { $0 == .end }
            .withLatestFrom(reactor.state.map { $0.canTimeSetSave })
            .subscribe(onNext: { [weak self] in
                guard let viewController = self?.coordinator.present(for: .timeSetEnd(reactor.timeSet.history, canSave: $0), animated: true) as? TimeSetEndViewController else { return }
                self?.bind(end: viewController)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(end viewController: TimeSetEndViewController) {
        guard let reactor = reactor else { return }
        
        // Close
        viewController.rx.close
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self?.coordinator.present(for: .dismiss, animated: false)
            })
            .disposed(by: disposeBag)
        
        // Overtime record
        viewController.rx.overtime
            .do(onNext: { [weak self] in self?.bubbleAlert = nil }) // Remove alert
            .map { .startOvertimeRecord }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Restart
        viewController.rx.restart
            .withLatestFrom(reactor.state.map { $0.canTimeSetSave })
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetProcess(reactor.origin, canSave: $0), animated: true) })
            .disposed(by: disposeBag)
    }
    
    func bind(popup: TimeSetPopup) {
        guard let reactor = reactor else { return }
        // Dispose previous event stream
        popupDisposeBag = DisposeBag()
        
        Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] _ in self?.dismissTimeSetPopup() })
            .disposed(by: popupDisposeBag)
        
        popup.confirmButton.rx.tap
            .map { Reactor.Action.stopAlarm }
            .bind(to: reactor.action)
            .disposed(by: popupDisposeBag)
        
        popup.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismissTimeSetPopup() })
            .disposed(by: popupDisposeBag)
    }
    
    func bind(alert: BubbleAlert, confirmHandler: @escaping () -> Void) {
        alertDisposeBag = DisposeBag()
        
        Observable.merge(
            alert.rx.cancel.asObservable(),
            alert.rx.confirm.asObservable())
            .subscribe(onNext: {[weak self] in self?.bubbleAlert = nil })
            .disposed(by: alertDisposeBag)
        
        alert.rx.confirm
            .subscribe(onNext: { confirmHandler() })
            .disposed(by: alertDisposeBag)
    }
    
    // MARK: - action method
    /// Handle badge select action with time set state
    private func badgeSelect(at indexPath: IndexPath) {
        timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: true)
        showTimerStartAlert(at: indexPath)
    }
    
    /// Show start timer with selected index alert
    private func showTimerStartAlert(at indexPath: IndexPath) {
        // Create alert & binding
        let alert = BubbleAlert(text: String(format: "time_set_alert_timer_start_title_format".localized, indexPath.row + 1), type: .confirm)
        bind(alert: alert) { [weak self] in self?.reactor?.action.onNext(.startTimeSet(at: indexPath.row)) }
        
        // Set constraint of alert
        view.addAutolayoutSubview(alert)
        alert.snp.makeConstraints { make in
            make.leading.equalTo(timerBadgeCollectionView).inset(60.adjust())
            make.bottom.equalTo(timerBadgeCollectionView.snp.top).inset(-3.adjust())
        }

        bubbleAlert = alert
    }
    
    // MARK: - state method
    /// Scroll badge if view can scroll
    private func scrollBadgeIfCan(at indexPath: IndexPath) {
        guard bubbleAlert == nil else { return }
        timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: true)
    }
    
    /// Get current countdown state string
    private func getTimeSetStateByCountdown(_ countdown: Int, state: JSTimer.State) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.codGray
        ]
        
        var string = ""
        switch state {
        case .run:
            guard countdown > 0 else { break }
            string = String(format: "time_set_state_countdown_format".localized, countdown)
            
        case .pause:
            string = "time_set_state_pause_title".localized
            
        default:
            break
        }
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    /// Get current time set state string
    private func getTimeSetState(_ state: TimeSet.State, history: History) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.codGray
        ]
        
        var string = ""
        switch state {
        case .pause:
            return NSAttributedString(string: "time_set_state_pause_title".localized, attributes: attributes)
            
        case .run:
            if history.endState != .none {
                // Set overtime attributes
                attributes[.foregroundColor] = Constants.Color.carnation
                string = "time_set_state_overtime_title".localized
            }
            
        default:
            break
        }
        
        if history.repeatCount > 0 {
            // Append repetition state
            string += string.isEmpty ? "" : ", "
            
            string += String(format: history.repeatCount == 1 ?
                "time_set_state_repeat_format".localized :
                "time_set_state_repeat_plural_format".localized,
                             history.repeatCount)
        }
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    /// Show time set popup about both timer end and time set end
    private func showTimeSetPopup(index: Int, count: Int, isRepeat: Bool, repeatCount: Int) {
        if index < count - 1 {
            showTimeSetPopup(title: String(format: "time_set_popup_timer_end_title_format".localized, index + 1),
                             subtitle: String(format: "time_set_popup_timer_end_info_format".localized, index + 1, count))
        } else {
            if isRepeat {
                showTimeSetPopup(title: String(format: "time_set_popup_time_set_repeat_title".localized),
                                 subtitle: String(format: "time_set_popup_time_set_repeat_info_format".localized, repeatCount))
            }
        }
    }
    
    /// Update layout by current state of time set
    private func updateLayoutByTimeSetState(_ state: TimeSet.State, history: History, canSave: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        
        switch state {
        case .pause:
            // Update hightlight button to restart button
            guard let button = footerView.buttons.first else { return }
            footerView.buttons = [button, startButton]
            
        case .run:
            // Prevent screen off when timer running
            UIApplication.shared.isIdleTimerDisabled = true
            
            switch history.endState {
            case .none:
                // Running time set
                footerView.buttons = [stopButton, pauseButton]
                
                // Set view enable
                timeSetProcessView.isEnabled = true
                
            default:
                // Running overtime recording
                footerView.buttons = [quitButton, pauseButton]
                
                // Set view disabled
                timeSetProcessView.isEnabled = false
                timeLabel.textColor = Constants.Color.carnation
            }
            
        case .end:
            // Present end view
            if history.endState == .normal {
                guard let viewController = coordinator.present(for: .timeSetEnd(history, canSave: canSave), animated: true) as? TimeSetEndViewController else { return }
                bind(end: viewController)
            }
            
        default:
            break
        }
    }
    
    /// Update layout by countdown state
    private func updateLayoutByCountdownState(_ state: JSTimer.State) {
        switch state {
        case .run:
            footerView.buttons = [stopButton, pauseButton]
            
        case .pause:
            footerView.buttons = [stopButton, startButton]
            
        default:
            break
        }
    }
    
    // MARK: - private method
    /// Show timer & time set info popup
    private func showTimeSetPopup(title: String, subtitle: String) {
        // Create popup view
        let timeSetPopup = TimeSetPopup(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height))
        timeSetPopup.frame.origin.x = (view.bounds.width - timeSetPopup.frame.width) / 2
        
        // Set properties
        timeSetPopup.title = title
        timeSetPopup.subtitle = subtitle
        
        // Add subview & binding
        view.addSubview(timeSetPopup)
        bind(popup: timeSetPopup)

        // Show view with animation
        timeSetPopup.show {
            self.timeSetPopup = timeSetPopup
        }
    }
    
    /// Dismiss timer & time set info popup
    private func dismissTimeSetPopup() {
        // Dismiss view with animation
        timeSetPopup?.dismiss {
            self.timeSetPopup = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
