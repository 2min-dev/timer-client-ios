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

class TimeSetDetailViewController: BaseHeaderViewController, View {
    // MARK: - constraints
    private let FOOTER_BUTTON_EDIT = 0
    private let FOOTER_BUTTON_START = 1
    
    // MARK: - view properties
    private var timeSetDetailView: TimeSetDetailView { return view as! TimeSetDetailView }
    
    override var headerView: CommonHeader { return timeSetDetailView.headerView }
    
    private var titleLabel: UILabel { return timeSetDetailView.titleLabel }
    
    private var allTimeLabel: UILabel { return timeSetDetailView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetDetailView.endOfTimeSetLabel }
    private var alarmLabel: UILabel { return timeSetDetailView.alarmLabel }
    private var commentTextView: UITextView { return timeSetDetailView.commentTextView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetDetailView.timerBadgeCollectionView }
    
    private var editButton: FooterButton { return timeSetDetailView.editButton }
    private var startButton: FooterButton { return timeSetDetailView.startButton }
    
    // MARK: - properties
    var coordinator: TimeSetDetailViewCoordinator
    
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<TimerBadgeSectionModel>(configureCell: { (dataSource, collectionView, indexPath, cellType) -> UICollectionViewCell in
        switch cellType {
        case let .regular(reactor):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeCollectionViewCell.name, for: indexPath) as? TimerBadgeCollectionViewCell else { fatalError() }
            cell.reactor = reactor
            
            return cell
            
        case .extra(_):
            fatalError("This view can't present extra cells of timer badge collection view")
        }
    })
    
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
        timerBadgeCollectionView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .withLatestFrom(reactor.state.map { $0.selectedIndex }, resultSelector: { ($0, $1) })
            .filter { $0.0.section == TimerBadgeSectionType.regular.rawValue }
            .map { Reactor.Action.selectTimer(at: $0.0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetEdit(reactor.timeSetInfo))})
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .withLatestFrom(reactor.state
                .map { $0.selectedIndex }
                .distinctUntilChanged())
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetProcess(reactor.timeSetInfo, start: $0)) })
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
            .share(replay: 1)
        
        // Alarm
        timer.map { $0.alarm }
            .bind(to: alarmLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Comment
        timer.map { $0.comment }
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Timer badge
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: timerBadgeCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .map { IndexPath(item: $0, section: TimerBadgeSectionType.regular.rawValue) }
            .subscribe(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: true) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    override func handleHeaderAction(_ action: CommonHeader.Action) {
        super.handleHeaderAction(action)
        
        switch action {
        case .bookmark:
            reactor?.action.onNext(.toggleBookmark)
            
        default:
            break
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
