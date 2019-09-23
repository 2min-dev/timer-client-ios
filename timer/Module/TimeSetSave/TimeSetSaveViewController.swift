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

class TimeSetSaveViewController: BaseViewController, View {
    // MARK: - constants
    private let FOOTER_BUTTON_CANCEL = 0
    private let FOOTER_BUTTON_CONFIRM = 1
    
    // MARK: - view properties
    private var timeSetSaveView: TimeSetSaveView { return view as! TimeSetSaveView }
    
    private var headerView: CommonHeader { return timeSetSaveView.headerView }
    private var contentView: UIView { return timeSetSaveView.contentView }
    
    private var titleTextField: UITextField { return timeSetSaveView.titleTextField }
    private var titleClearButton: UIButton { return timeSetSaveView.titleClearButton }
    private var titleHintLabel: UILabel { return timeSetSaveView.titleHintLabel }
    
    private var allTimeLabel: UILabel { return timeSetSaveView.allTimeLabel}
    private var endOfTimeSetLabel: UILabel { return timeSetSaveView.endOfTimeSetLabel }
    
    private var timerOptionView: UIView { return timeSetSaveView.timerOptionView }
    private var timerOptionViewController: TimerOptionViewController!
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetSaveView.timerBadgeCollectionView }
    
    private var footerView: Footer { return timeSetSaveView.footerView }
    
    // MARK: - properties
    var coordinator: TimeSetSaveViewCoordinator
    
    private var isDragging: Bool = false
    
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
        
        // Add timer option view controller
        if let timerOptionNavigationController = coordinator.get(for: .timerOption) as? UINavigationController,
            let timerOptionViewController = timerOptionNavigationController.viewControllers.first as? TimerOptionViewController {
            addChild(timerOptionNavigationController, in: timerOptionView)
            self.timerOptionViewController = timerOptionViewController
        }
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetSaveViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .filter { $0 == .back }
            .subscribe(onNext: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
        
        titleTextField.rx.text
            .orEmpty
            .skipUntil(rx.viewWillAppear)
            .map { Reactor.Action.updateTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleClearButton.rx.tap
            .map { Reactor.Action.clearTitle }
            .do(onNext: { [weak self] _ in self?.titleTextField.becomeFirstResponder() })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        timerBadgeCollectionView.rx.badgeSelected
            .do(onNext: { [weak self] in self?.scrollToBadgeIfCan(at: $0.0) })
            .map { Reactor.Action.selectTimer(at: $0.0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Timer badge collection view dragging
        timerBadgeCollectionView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in self?.isDragging = true })
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.didEndDecelerating
            .subscribe(onNext: { [weak self] in self?.isDragging = false })
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.didScroll
            .filter { [unowned self] in self.isDragging }
            .map { [weak self] in self?.getIndexPathFromScrolling() }
            .filter { $0 != nil }
            .map { Reactor.Action.selectTimer(at: $0!) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        timerOptionViewController.rx.alarmApplyAll
            .map { Reactor.Action.applyAlarm($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        timerOptionViewController.rx.delete
            .map { Reactor.Action.deleteTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        footerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.footerActionHandler(index: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Hint of title text field
        reactor.state
            .map { $0.hint }
            .bind(to: titleHintLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Title of time set
        reactor.state
            .map { $0.title }
            .filter { [weak self] in $0 != self?.titleTextField.text }
            .bind(to: titleTextField.rx.text)
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
        
        // Timer badge view
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { ($0.timers, nil, nil) }
            .bind(to: timerBadgeCollectionView.rx.items)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in self?.scrollToBadgeIfCan(at: $0) })
            .bind(to: timerBadgeCollectionView.rx.selected)
            .disposed(by: disposeBag)
        
        // Timer option view
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged { $0 === $1 }
            .do(onNext: { [weak self] _ in self?.timerOptionViewController.navigationController?.popViewController(animated: true) })
            .bind(to: timerOptionViewController.rx.timer)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath.row + 1 }
            .distinctUntilChanged()
            .map { String(format: "timer_option_title_format".localized, $0) }
            .bind(to: timerOptionViewController.rx.title)
            .disposed(by: disposeBag)
        
        // Alert
        reactor.state
            .map { $0.alertMessage }
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [weak self] in self?.showAlert(message: $0) })
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
    
    // MARK: - private method
    private func footerActionHandler(index: Int) {
        if index == FOOTER_BUTTON_CANCEL {
            // Cancel -> Pop view controller
            navigationController?.popViewController(animated: true)
        } else if index == FOOTER_BUTTON_CONFIRM {
            guard let reactor = reactor else { return }
            // Confirm -> Save time set
            reactor.action.onNext(.saveTimeSet)
        }
    }
    
    /// Get time set info's attributed string
    private func getTimeSetInfoString(title: String, info: String) -> NSAttributedString {
        let title = NSAttributedString(string: title,
                                       attributes: [
                                        .font: Constants.Font.Regular.withSize(12.adjust())
        ])
        let time = NSAttributedString(string: info,
                                      attributes: [
                                        .font: Constants.Font.Bold.withSize(12.adjust())
        ])
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(title)
        attributedString.append(time)
        return attributedString
    }
    
    /// Get index path from badge view scrolling
    private func getIndexPathFromScrolling() -> IndexPath? {
        guard let layout = timerBadgeCollectionView.collectionViewLayout as? TimerBadgeCollectionViewFlowLayout else { return nil }
        let axisPoint = layout.axisPoint
        
        let frame = timerBadgeCollectionView.frame
        let origin = CGPoint(x: axisPoint.x, y: frame.origin.y + frame.height / 2) // Get center point of axis
        let converted = self.contentView.convert(origin, to: timerBadgeCollectionView)
        
        return timerBadgeCollectionView.indexPathForItem(at: converted)
    }
    
    /// Scroll to badge if can scroll
    private func scrollToBadgeIfCan(at: IndexPath) {
        guard !isDragging else { return }
        timerBadgeCollectionView.scrollToBadge(at: at, animated: true)
    }
    
    /// Show popup alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        // Alert view controller dismiss after 1 seconds
        alert.rx.viewDidLoad
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak alert] in alert?.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        // Present alert view controller
        present(alert, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
