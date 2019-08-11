//
//  TimeSetDetailViewController.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetDetailViewController: BaseViewController, View {
    // MARK: - constraints
    private let FOOTER_BUTTON_EDIT = 0
    private let FOOTER_BUTTON_START = 1
    
    // MARK: - view properties
    private var timeSetDetailView: TimeSetDetailView { return view as! TimeSetDetailView }
    
    private var headerView: CommonHeader { return timeSetDetailView.headerView }
    
    private var titleLabel: UILabel { return timeSetDetailView.titleLabel }
    private var sumOfTimersLabel: UILabel { return timeSetDetailView.sumOfTimersLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetDetailView.endOfTimeSetLabel }
    private var loopButton: UIButton { return timeSetDetailView.loopButton }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetDetailView.timerBadgeCollectionView }
    
    private var alarmLabel: UILabel { return timeSetDetailView.alarmLabel }
    private var commentTextView: UITextView { return timeSetDetailView.commentTextView }
    
    private var footerView: Footer { return timeSetDetailView.footerView }
    
    // MARK: - properties
    var coordinator: TimeSetDetailViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetDetailViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetDetailViewReactor) {
        // MARK: action
        loopButton.rx.tap
            .map { Reactor.Action.toggleLoop }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeSelected
            .map { Reactor.Action.selectTimer(at: $0.0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0)})
            .disposed(by: disposeBag)
        
        footerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.footerActionHandler(index: $0)})
            .disposed(by: disposeBag)
        
        // MARK: state
        // Bookmark
        reactor.state
            .map { $0.isBookmark }
            .distinctUntilChanged()
            .filter { [weak self] _ in self?.headerView.buttons[.bookmark] != nil }
            .bind(to: headerView.buttons[.bookmark]!.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Sum of timers
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_sum_of_all_timers_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: sumOfTimersLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.sumOfTimers }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: RxTimeInterval.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        )
            .observeOn(MainScheduler.instance)
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_expected_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Loop
        reactor.state
            .map { $0.isLoop }
            .distinctUntilChanged()
            .bind(to: loopButton.rx.isSelected)
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
    }
    
    // MARK: - priate method
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
            break
        default:
            break
        }
    }
    /// Handle footer button tap action according to button index
    private func footerActionHandler(index: Int) {
        if index == FOOTER_BUTTON_EDIT {
            // Edit -> Present time set edit
            guard let reactor = reactor else { return }
            _ = coordinator.present(for: .timeSetEdit(reactor.timeSetInfo))
        } else if index == FOOTER_BUTTON_START {
            // Start -> Present time set precess
            // TODO: Present time set precess
        }
    }
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
