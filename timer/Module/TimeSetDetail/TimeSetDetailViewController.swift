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
    private var allTimeLabel: UILabel { return timeSetDetailView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetDetailView.endOfTimeSetLabel }
    private var repeatButton: UIButton { return timeSetDetailView.repeatButton }
    
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
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .map { Reactor.Action.toggleRepeat }
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
                .map { $0.allTime }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: .seconds(30), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)))
            .observeOn(MainScheduler.instance)
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Repeat
        reactor.state
            .map { $0.isRepeat }
            .distinctUntilChanged()
            .bind(to: repeatButton.rx.isSelected)
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
    
    /// Handle footer button tap action according to button index
    private func footerActionHandler(index: Int) {
        guard let reactor = reactor else { return }
        if index == FOOTER_BUTTON_EDIT {
            // Edit -> Present time set edit
            _ = coordinator.present(for: .timeSetEdit(reactor.timeSetInfo))
        } else if index == FOOTER_BUTTON_START {
            // Start -> Present time set precess
            _ = coordinator.present(for: .timeSetProcess(reactor.timeSetInfo))
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
