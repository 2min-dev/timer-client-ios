//
//  TimeSetSaveViewController.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class TimeSetSaveViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - constants
    private let MAX_TITLE_LENGTH: Int = 20
    
    // MARK: - view properties
    private var timeSetSaveView: TimeSetSaveView { return view as! TimeSetSaveView }
    
    override var headerView: CommonHeader { return timeSetSaveView.headerView }
    
    private var titleTextField: UITextField { return timeSetSaveView.titleTextField }
    private var titleClearButton: UIButton { return timeSetSaveView.titleClearButton }
    private var titleHintLabel: UILabel { return timeSetSaveView.titleHintLabel }
    
    private var allTimeLabel: UILabel { return timeSetSaveView.allTimeLabel }
    private var endOfTimeSetLabel: UILabel { return timeSetSaveView.endOfTimeSetLabel }
    private var alarmLabel: UILabel { return timeSetSaveView.alarmLabel }
    private var commentTextView: UITextView { return timeSetSaveView.commentTextView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetSaveView.timerBadgeCollectionView }
    
    private var cancelButton: FooterButton { return timeSetSaveView.cancelButton }
    private var confirmButton: FooterButton { return timeSetSaveView.confirmButton }
    
    // MARK: - properties
    var coordinator: TimeSetSaveViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetSaveViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetSaveView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        titleTextField.rx.textChanged
            .compactMap { $0 }
            .map { !$0.isEmpty }
            .bind(to: titleHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        titleTextField.rx.textChanged
            .compactMap { $0 }
            .map { $0.isEmpty }
            .bind(to: titleClearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        titleTextField.rx.text
            .orEmpty
            .map { ($0, $0.lengthOfBytes(using: .euc_kr)) }
            .filter { [weak self] in $0.1 > (self?.MAX_TITLE_LENGTH ?? 0) }
            .map { String($0.0.dropLast()) }
            .bind(to: titleTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetSaveViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.titleTextField.becomeFirstResponder() })
            .disposed(by: disposeBag)
        
        titleTextField.rx.text
            .skip(1)
            .compactMap { $0 }
            .map { Reactor.Action.updateTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleClearButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .do(onNext: { [weak self] _ in self?.titleTextField.becomeFirstResponder() })
            .map { Reactor.Action.clearTitle }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.itemSelected
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .filter { $0.section == TimerBadgeSectionType.regular.rawValue }
            .map { Reactor.Action.selectTimer(at: $0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismissOrPopViewController(animated: true) })
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .map { Reactor.Action.saveTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .filter { [weak self] in self?.titleTextField.text != $0 }
            .bind(to: titleTextField.rx.text)
            .disposed(by: disposeBag)
        
        // Hint of title text field
        reactor.state
            .map { $0.hint }
            .distinctUntilChanged()
            .bind(to: titleHintLabel.rx.text)
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
            .map { Date().addingTimeInterval($0.0) }
            .map { getDateString(format: "time_set_end_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimeSetLabel.rx.text)
            .disposed(by: disposeBag)
        
        let timer = reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
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
            .subscribe(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: true) })
            .disposed(by: disposeBag)

        // Time set saved
        reactor.state
            .map { $0.savedTimeSet }
            .distinctUntilChanged { $0 === $1 }
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance) // Ignore rx error
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .timeSetDetail($0!)) })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
