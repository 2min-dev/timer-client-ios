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
import RxDataSources

class TimeSetDetailViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - constraints
    private let FOOTER_BUTTON_EDIT = 0
    private let FOOTER_BUTTON_START = 1
    
    // MARK: - view properties
    private var timeSetDetailView: TimeSetDetailView { view as! TimeSetDetailView }
    
    override var headerView: CommonHeader { timeSetDetailView.headerView }
    
    private var titleLabel: UILabel { timeSetDetailView.titleLabel }
    
    private var allTimeLabel: UILabel { timeSetDetailView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { timeSetDetailView.endOfTimeSetLabel }
    private var alarmLabel: UILabel { timeSetDetailView.alarmLabel }
    private var commentTextView: UITextView { timeSetDetailView.commentTextView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { timeSetDetailView.timerBadgeCollectionView }
    
    private var footerView: Footer { timeSetDetailView.footerView }
    private var saveButton: FooterButton { timeSetDetailView.saveButton }
    private var editButton: FooterButton { timeSetDetailView.editButton }
    private var startButton: FooterButton { timeSetDetailView.startButton }
    
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
    
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetDetailViewReactor) {
        // MARK: action
        timerBadgeCollectionView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .withLatestFrom(reactor.state.map { $0.selectedIndex }, resultSelector: { ($0, $1) })
            .filter { $0.0.section == TimerBadgeSectionType.regular.rawValue }
            .map { .selectTimer(at: $0.0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { .saveTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetEdit(reactor.timeSetItem), animated: true)})
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .withLatestFrom(reactor.state
                .map { $0.selectedIndex }
                .distinctUntilChanged())
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetItem, startAt: $0, canSave: false), animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
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
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
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
        
        let timer = reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
            .share()
        
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
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: timerBadgeCollectionView.rx.items(dataSource: timerBadgeCollectionView._dataSource))
            .disposed(by: disposeBag)
        
        let selectedIndex = reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .share()
        
        selectedIndex
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: true) })
            .disposed(by: disposeBag)
        
        selectedIndex
            .skipUntil(rx.viewDidAppear)
            .subscribe(onNext: { _ in Toast(content: "toast_time_set_timer_selected_title".localized).show(animated: true, withDuration: 3) })
            .disposed(by: disposeBag)
        
        // Time set can save
        reactor.state
            .map { $0.canTimeSetSave }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateLayout(timeSet: $0) })
            .disposed(by: disposeBag)
        
        // Time set did saved
        reactor.state
            .map { $0.didTimeSetSaved }
            .distinctUntilChanged()
            .compactMap { $0.value }
            .filter { $0 }
            .subscribe(onNext: { _ in Toast(content: "toast_time_set_saved_title".localized).show(animated: true, withDuration: 3) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: CommonHeader.Action) {
        switch action {
        case .back:
            coordinator.present(for: .dismiss, animated: true)
            
        default:
            break
        }
    }
    
    /// Update layout by time set can save
    private func updateLayout(timeSet canSave: Bool) {
        footerView.buttons = canSave ? [saveButton, startButton] : [editButton, startButton]
    }
    
    deinit {
        Logger.verbose()
    }
}
