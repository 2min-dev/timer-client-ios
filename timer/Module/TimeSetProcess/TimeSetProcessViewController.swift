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

class TimeSetProcessViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetProcessView: TimeSetProcessView { return view as! TimeSetProcessView }
    
    private var headerView: CommonHeader { return timeSetProcessView.headerView }
    
    private var timeSetBadge: TimeSetBadge { return timeSetProcessView.timeSetBadge }
    private var titleLabel: UILabel { return timeSetProcessView.titleLabel }
    private var timeLabel: UILabel { return timeSetProcessView.timeLabel }
    private var allTimeLabel: UILabel { return timeSetProcessView.allTimeLabel }
    private var extraTimeLabel: UILabel { return timeSetProcessView.extraTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetProcessView.endOfTimeSetLabel }
    
    private var repeatButton: UIButton { return timeSetProcessView.repeatButton }
    private var plus1MinButton: UIButton { return timeSetProcessView.plus1MinButton }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetProcessView.timerBadgeCollectionView }
    private var memoButton: MemoButton { return timeSetProcessView.memoButton }
    
    private var alarmLabel: UILabel { return timeSetProcessView.alarmLabel }
    private var commentTextView: UITextView { return timeSetProcessView.commentTextView }
    
    private var editButton: FooterButton { return timeSetProcessView.editButton }
    private var startButton: FooterButton { return timeSetProcessView.startButton }
    private var stopButton: FooterButton { return timeSetProcessView.stopButton }
    private var pauseButton: FooterButton { return timeSetProcessView.pauseButton }
    private var restartButton: FooterButton { return timeSetProcessView.restartButton }
    private var footerView: Footer { return timeSetProcessView.footerView }
    
    private var timeSetEndView: TimeSetEndView { return timeSetProcessView.timeSetEndView }
    private var dimView: UIView?
    
    // MARK: - properties
    var coordinator: TimeSetProcessViewCoordinator
    
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
    
    override func bind() {
        timeSetEndView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true)})
            .disposed(by: disposeBag)
        
        timeSetEndView.excessButton.rx.tap
            .do(onNext: { [weak self] in self?.dissmissTimeSetEndView() })
            .subscribe(onNext: {
                Logger.debug("Excess record")
                // TODO: Excess record time set
            })
            .disposed(by: disposeBag)
        
        timeSetEndView.restartButton.rx.tap
            .do(onNext: { [weak self] in self?.dissmissTimeSetEndView() })
            .subscribe(onNext: { [weak self] in
                guard let reactor = self?.reactor else { return }
                _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetInfo, start: 0))
            })
            .disposed(by: disposeBag)
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
            .subscribe(onNext: { [weak self] in
                self?.timerBadgeCollectionView.scrollToBadge(at: reactor.currentState.selectedIndexPath, animated: false)
            })
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .map { Reactor.Action.toggleRepeat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        plus1MinButton.rx.tap
            .map { Reactor.Action.addExtraTime(TimeInterval(Constants.Time.minute)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeSelected
            .map { Reactor.Action.startTimeSet(at: $0.0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoButton.rx.tap
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetMemo(reactor.timeSet)) })
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0)})
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetInfo, start: 0)) })
            .disposed(by: disposeBag)
        
        restartButton.rx.tap
            .map { Reactor.Action.startTimeSet(at: nil) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        stopButton.rx.tap
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
            .filter { [weak self] _ in self?.headerView.buttons[.bookmark] != nil }
            .bind(to: headerView.buttons[.bookmark]!.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Badge
        reactor.state
            .map { $0.countdown }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in self?.timeSetBadge.isHidden = ($0 == 0) })
            .map { TimeSetBadge.BadgeType.countdown(time: $0) }
            .bind(to: timeSetBadge.rx.type)
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
            .filter { [weak self] in !(self?.isTimeSetEnd(state: $0.0) ?? true) }
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
        
        // Add time
        reactor.state
            .map { $0.extraTime < TimeSetProcessViewReactor.MAX_EXTRA_TIME }
            .distinctUntilChanged()
            .bind(to: plus1MinButton.rx.isEnabled)
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
            .do(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: true) })
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
        
        reactor.state
            .map { $0.timeSetState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateLayoutByTimeSetState($0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.countdownState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateLayoutByCountdownState($0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    private func headerActionHandler(type: CommonHeader.ButtonType) {
        switch type {
        case .back:
            navigationController?.popViewController(animated: true)
        case .share:
            break
        case .bookmark:
            guard let reactor = reactor else { return }
            reactor.action.onNext(.toggleBookmark)
        case .home:
            _ = coordinator.present(for: .home)
        default:
            break
        }
    }
    
    // MARK: - state method
    private func isTimeSetEnd(state: TimeSet.State) -> Bool {
        if case .end(detail: _) = state {
            return true
        } else {
            return false
        }
    }
    
    private func updateLayoutByCountdownState(_ state: TimeSetProcessViewReactor.CountdownState) {
        switch state {
        case .run:
            footerView.buttons = [stopButton, pauseButton]
            plus1MinButton.isEnabled = false
            
        case .pause:
            footerView.buttons = [stopButton, restartButton]
            
        case .done:
            plus1MinButton.isEnabled = true
            
        default:
            break
        }
    }
    
    /// Update layout by current state of time set
    private func updateLayoutByTimeSetState(_ state: TimeSet.State) {
        switch state {
        case .initialize:
            footerView.buttons = [stopButton, pauseButton]
            
        case let .run(repeat: count):
            footerView.buttons = [stopButton, pauseButton]
            
            timeSetBadge.isHidden = count == 0 ? true : false
            timeSetBadge.setBadgeType(.repeat(count: count))
            
        case .pause:
            footerView.buttons = [stopButton, restartButton]
        
        case let .end(detail: endState):
            footerView.buttons = [editButton, startButton]
            
            switch endState {
            case .cancel:
                timeSetBadge.isHidden = false
                timeSetBadge.setBadgeType(.cancel)
                
            case .excess:
                timeSetBadge.isHidden = false
                timeSetBadge.setBadgeType(.excess)
                
            case .normal:
                showTimeSetEndView()
            }
            
        default:
            break
        }
    }
    
    // MARK: - private method
    /// Show time set end view
    private func showTimeSetEndView() {
        guard let reactor = reactor else { return }
        
        // Inject reactor
        timeSetEndView.reactor = TimeSetEndViewReactor(timeSet: reactor.timeSet)
        
        // Show view with animation
        timeSetEndView.show(animated: true)
    }
    
    /// Dismiss time set end view
    private func dissmissTimeSetEndView() {
        // Dismiss view with animation
        timeSetEndView.dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
