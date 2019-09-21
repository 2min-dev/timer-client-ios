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

class TimeSetProcessViewController: BaseHeaderViewController, View {
    // MARK: - view properties
    private var timeSetProcessView: TimeSetProcessView { return view as! TimeSetProcessView }
    
    override var headerView: CommonHeader { return timeSetProcessView.headerView }
    
    private var timeSetBadge: TimeSetBadge { return timeSetProcessView.timeSetBadge }
    private var titleLabel: UILabel { return timeSetProcessView.titleLabel }
    private var timeLabel: UILabel { return timeSetProcessView.timeLabel }
    private var allTimeLabel: UILabel { return timeSetProcessView.allTimeLabel }
    private var extraTimeLabel: UILabel { return timeSetProcessView.extraTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetProcessView.endOfTimeSetLabel }
    
    private var repeatButton: UIButton { return timeSetProcessView.repeatButton }
    private var addTimeButton: UIButton { return timeSetProcessView.addTimeButton }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetProcessView.timerBadgeCollectionView }
    private var memoButton: MemoButton { return timeSetProcessView.memoButton }
    
    private var alarmLabel: UILabel { return timeSetProcessView.alarmLabel }
    private var commentTextView: UITextView { return timeSetProcessView.commentTextView }
    
    private var editButton: FooterButton { return timeSetProcessView.editButton }
    private var startButton: FooterButton { return timeSetProcessView.startButton }
    private var stopButton: FooterButton { return timeSetProcessView.stopButton }
    private var quitButton: FooterButton { return timeSetProcessView.quitButton }
    private var pauseButton: FooterButton { return timeSetProcessView.pauseButton }
    private var restartButton: FooterButton { return timeSetProcessView.restartButton }
    private var footerView: Footer { return timeSetProcessView.footerView }
    
    private var timeSetPopup: TimeSetPopup? {
        didSet { oldValue?.removeFromSuperview() }
    }
    private var timeSetAlert: TimeSetAlert? {
        didSet {
            oldValue?.removeFromSuperview()
            timerBadgeCollectionView.isScrollEnabled = timeSetAlert == nil
        }
    }
    private var timeSetEndView: TimeSetEndView? {
        didSet {
            oldValue?.dismiss(animated: false) {
                oldValue?.removeFromSuperview()
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetProcessViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Init badge
        rx.viewDidLayoutSubviews
            .takeUntil(rx.viewDidAppear)
            .subscribe(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: reactor.currentState.selectedIndexPath, animated: false) })
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .map { Reactor.Action.toggleRepeat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addTimeButton.rx.tap
            .map { Reactor.Action.addExtraTime(TimeInterval(Constants.Time.minute)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeSelected
            .withLatestFrom(reactor.state.map { $0.timeSetState }, resultSelector: { ($0.0, $0.1, $1) })
            .subscribe(onNext: { [weak self] (indexPath, _, state) in self?.badgeSelect(at: indexPath, withTimeSetState: state) })
            .disposed(by: disposeBag)
        
        memoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                _ = self?.coordinator.present(for: .timeSetMemo(reactor.timeSet, origin: reactor.timeSetInfo))
            })
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetInfo)) })
            .disposed(by: disposeBag)
        
        restartButton.rx.tap
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
        // Bookmark
        reactor.state
            .map { $0.isBookmark }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                guard let bookmark = self?.headerView.buttons[.bookmark] else { return }
                bookmark.isSelected = $0
            })
            .disposed(by: disposeBag)
        
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
        
        // All time
        reactor.state
            .map { $0.allTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_all_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: allTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.timeSetState }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.remainedTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(30), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .observeOn(MainScheduler.instance)
            .filter { [weak self] in !(self?.isTimeSetEnded(state: $0.0) ?? true) }
            .map { Date().addingTimeInterval($0.1) }
            .map { getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimeSetLabel.rx.text)
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
        
        // Repeat
        reactor.state
            .map { $0.isRepeat }
            .distinctUntilChanged()
            .bind(to: repeatButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Time set badge
        reactor.state
            .map { $0.repeatCount }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in self?.timeSetBadge.isHidden = $0 == 0 })
            .filter { $0 > 0 }
            .map { TimeSetBadge.BadgeType.repeat(count: $0) }
            .bind(to: timeSetBadge.rx.type)
            .disposed(by: disposeBag)
        
        // Add time
        reactor.state
            .map { $0.extraTime < TimeSetProcessViewReactor.MAX_EXTRA_TIME }
            .distinctUntilChanged()
            .bind(to: addTimeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Timer badge view
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.timers }
            .bind(to: timerBadgeCollectionView.rx.items)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in self?.scrollToBadgeIfCan(at: $0) })
            .bind(to: timerBadgeCollectionView.rx.selected)
            .disposed(by: disposeBag)
        
        // Alarm
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged { $0 === $1 }
            .map { $0.alarm }
            .bind(to: alarmLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Comment
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged { $0 === $1 }
            .map { $0.comment }
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)

        // Timer end popup
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .skipUntil(rx.viewWillAppear)
            .withLatestFrom(reactor.state.map { ($0.timers.count, $0.timeSetState) }, resultSelector: { ($0.row, $1.0, $1.1) })
            .filter { $2 == .run(detail: .normal) }
            .subscribe(onNext: { [weak self] in
                self?.showTimeSetPopup(title: String(format: "time_set_popup_timer_end_title_format".localized, $0.0),
                                       subtitle: String(format: "time_set_popup_timer_end_info_format".localized, $0.0, $0.1)) })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state
                .map { $0.timeSetState }
                .distinctUntilChanged(),
            rx.viewWillAppear
                .take(1))
            .map { $0.0 }
            .subscribe(onNext: { [weak self] in self?.updateLayoutByTimeSetState($0) })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.countdownState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateLayoutByCountdownState($0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
    }
    
    func bind(popup: TimeSetPopup) {
        // Dispose previous event stream
        popupDisposeBag = DisposeBag()
        
        Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] _ in self?.dismissTimeSetPopup() })
            .disposed(by: popupDisposeBag)
        
        popup.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismissTimeSetPopup() })
            .disposed(by: popupDisposeBag)
    }
    
    func bind(alert: TimeSetAlert, confirmHandler: @escaping () -> Void) {
        alertDisposeBag = DisposeBag()

        alert.cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.timeSetAlert = nil
            })
            .disposed(by: alertDisposeBag)
        
        alert.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.timeSetAlert = nil
                confirmHandler()
            })
            .disposed(by: alertDisposeBag)
    }
    
    func bind(endView: TimeSetEndView, reactor: TimeSetEndViewReactor) {
        guard let timeSetProcessReactor = self.reactor,
            let timeSet = self.reactor?.timeSet else { return }

        rx.viewWillAppear
            .map { TimeSetEndViewReactor.Action.updateMemo(timeSet.info.memo) }
            .bind(to: reactor.action)
            .disposed(by: endView.disposeBag)
        
        endView.closeButton.rx.tap
            .do(onNext: { [weak self] in self?.dissmissTimeSetEndView() })
            .subscribe(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true)})
            .disposed(by: endView.disposeBag)
        
        endView.overtimeButton.rx.tap
            .do(onNext: { [weak self] in self?.dissmissTimeSetEndView() })
            .map { Reactor.Action.startOvertimeRecord }
            .bind(to: timeSetProcessReactor.action)
            .disposed(by: endView.disposeBag)
        
        endView.restartButton.rx.tap
            .do(onNext: { [weak self] in self?.dissmissTimeSetEndView() })
            .subscribe(onNext: { [weak self] in
                guard let reactor = self?.reactor else { return }
                _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetInfo))
            })
            .disposed(by: endView.disposeBag)
    }
    
    // MARK: - action method
    override func handleHeaderAction(_ action: CommonHeader.Action) {
        super.handleHeaderAction(action)
        
        switch action {
        case .bookmark:
            reactor?.action.onNext(.toggleBookmark)
            
        case .home:
            _ = coordinator.present(for: .home)
            
        default:
            break
        }
    }
    
    /// Handle badge select action with time set state
    private func badgeSelect(at indexPath: IndexPath, withTimeSetState state: TimeSet.State) {
        switch state {
        case .initialize,
             .run(detail: .normal):
            timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: true)
            showTimerStartAlert(at: indexPath)
            
        case .run(detail: .overtime),
             .end(detail: _):
            reactor?.action.onNext(.selectTimer(at: indexPath.row))
            
        default:
            return
        }
    }
    
    /// Timer bage view scroll to selected badge if can
    private func scrollToBadgeIfCan(at indexPath: IndexPath) {
        guard timeSetAlert == nil else { return }
        timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: true)
    }
    
    /// Show start timer with selected index alert
    private func showTimerStartAlert(at indexPath: IndexPath) {
        guard let layout = timerBadgeCollectionView.layout else { return }
        
        // Create alert & binding
        let timeSetAlert = TimeSetAlert(text: String(format: "time_set_alert_timer_start_title_format".localized, indexPath.row + 1))
        bind(alert: timeSetAlert) { [weak self] in
            self?.reactor?.action.onNext(.startTimeSet(at: indexPath.row))
        }
        
        // Get selected cell size
        let cellSize = timerBadgeCollectionView.collectionView(timerBadgeCollectionView,
                                                               layout: layout,
                                                               sizeForItemAt: indexPath)
        let revisedXPos = layout.axisPoint.x + cellSize.width / 2 - timeSetAlert.tailPosition.x
        let revisedYPos = 15.adjust() + timeSetAlert.tailSize.height // Half of badge height (30 / 2)
        
        // Set constraint of alert
        view.addAutolayoutSubview(timeSetAlert)
        timeSetAlert.snp.makeConstraints { make in
            make.leading.equalTo(timerBadgeCollectionView).offset(revisedXPos)
            make.bottom.equalTo(timerBadgeCollectionView.snp.centerY).inset(-revisedYPos)
        }

        self.timeSetAlert = timeSetAlert
    }
    
    // MARK: - state method
    /// Get is time set ended
    private func isTimeSetEnded(state: TimeSet.State) -> Bool {
        guard case .end(detail: _) = state else { return false }
        return true
    }
    
    /// Update layout by countdown state
    private func updateLayoutByCountdownState(_ state: TimeSetProcessViewReactor.CountdownState) {
        switch state {
        case let .run(countdown: time):
            footerView.buttons = [stopButton, pauseButton]
            
            timeSetBadge.isHidden = time == 0
            timeSetBadge.setBadgeType(.countdown(time: time))
            
        case .pause:
            footerView.buttons = [stopButton, restartButton]
            
        default:
            break
        }
    }
    
    /// Update layout by current state of time set
    private func updateLayoutByTimeSetState(_ state: TimeSet.State) {
        UIApplication.shared.isIdleTimerDisabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        switch state {
        case .initialize:
            addTimeButton.isEnabled = false

        case let .stop(repeat: count):
            if count > 0 {
                // Show time set repeat popup
                showTimeSetPopup(title: "time_set_popup_time_set_repeat_title".localized,
                                 subtitle: String(format: "time_set_popup_time_set_repeat_info_format".localized, count))
            }
            
        case let .run(detail: runState):
            // Prevent screen off when timer running
            UIApplication.shared.isIdleTimerDisabled = true
            
            if runState == .normal {
                // Running time set
                footerView.buttons = [stopButton, pauseButton]
                
                addTimeButton.isEnabled = true
            } else {
                // Set disable that navigation controller pop gesture recognizer during overtime recording
                navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                // Running overtime recording
                footerView.buttons = [quitButton, pauseButton]
                
                // Set overtime badge
                timeSetBadge.isHidden = false
                timeSetBadge.setBadgeType(.overtime)
                
                timeLabel.textColor = Constants.Color.carnation
                timeSetProcessView.setEnable(false)
            }
            
        case .pause:
            // Update hightlight button to restart button
            guard let button = footerView.buttons.first else { return }
            footerView.buttons = [button, restartButton]
        
        case let .end(detail: endState):
            footerView.buttons = [editButton, startButton]

            timeSetProcessView.setEnable(true)
            addTimeButton.isEnabled = false // Disable add time button because time set ended
            
            switch endState {
            case .cancel:
                timeSetBadge.isHidden = false
                timeSetBadge.setBadgeType(.cancel)
                // Show time set memo induce alert
                showTimeSetMemoAlert(text: "time_set_alert_cancel_title".localized)
                
            case .normal:
                // Remove alert
                timeSetAlert = nil
                showTimeSetEndView()
                
            case .overtime:
                // Show time set memo induce alert
                showTimeSetMemoAlert(text: "time_set_alert_overtime_title".localized)
                
            default:
                break
            }
        }
    }
    
    // MARK: - private method
    /// Show time set canceled alert
    private func showTimeSetMemoAlert(text: String) {
        // Create alert & binding
        let timeSetAlert = TimeSetAlert(text: text)
        bind(alert: timeSetAlert) { [weak self] in
            guard let timeSet = self?.reactor?.timeSet,
                let timeSetInfo = self?.reactor?.timeSetInfo else { return }
            _ = self?.coordinator.present(for: .timeSetMemo(timeSet, origin: timeSetInfo))
        }
        
        let revisedXPos = timeSetAlert.tailPosition.x - 8.adjust()
        let revisedYPos = timeSetAlert.tailSize.height
        
        // Set constraint of alert
        view.addAutolayoutSubview(timeSetAlert)
        timeSetAlert.snp.makeConstraints { make in
            make.leading.equalTo(memoButton.snp.centerX).inset(-revisedXPos)
            make.bottom.equalTo(memoButton.snp.top).inset(-revisedYPos)
        }
        
        self.timeSetAlert?.removeFromSuperview()
        self.timeSetAlert = timeSetAlert
    }
    
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
    
    /// Show time set end view
    private func showTimeSetEndView() {
        guard let reactor = reactor, timeSetEndView == nil else { return }
        
        // Create time set end view
        let timeSetEndView = TimeSetEndView()
        
        // Inject reactor
        timeSetEndView.reactor = TimeSetEndViewReactor(timeSet: reactor.timeSet)
        
        // Add sub view and bind events
        view.addSubview(timeSetEndView)
        bind(endView: timeSetEndView, reactor: timeSetEndView.reactor!)
        
        // Show view with animation
        timeSetEndView.show {
            self.timeSetEndView = timeSetEndView
        }
    }
    
    /// Dismiss time set end view
    private func dissmissTimeSetEndView() {
        // Dismiss view with animation
        timeSetEndView?.dismiss(animated: true) {
            self.timeSetEndView = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
