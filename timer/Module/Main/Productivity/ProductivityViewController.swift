//
//  ProductivityViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import JSReorderableCollectionView

class ProductivityViewController: BaseViewController, View {
    // MARK: - constants
    private let MAX_TIMER_COUNT: Int = 10
    private let FOOTER_BUTTON_SAVE: Int = 0
    private let FOOTER_BUTTON_START: Int = 1
    
    // MARK: - view properties
    private var productivityView: ProductivityView { return view as! ProductivityView }
    
    private var headerView: CommonHeader { return productivityView.headerView }
    
    private var timerInputView: TimerInputView { return productivityView.timerInputView }
    private var timerClearButton: UIButton { return productivityView.timerInputView.timerClearButton }
    
    private var timeInfoView: UIView { return productivityView.timeInfoView }
    private var sumOfTimersLabel: UILabel { return productivityView.sumOfTimersLabel }
    private var endOfTimeSetLabel: UILabel { return productivityView.endOfTimeSetLabel }
    private var timerInputLabel: UILabel { return productivityView.timeInputLabel }
    
    private var keyPadView: KeyPad { return productivityView.keyPadView }
    
    private var timeButtonStackView: UIStackView { return productivityView.timeButtonStackView }
    private var hourButton: UIButton { return productivityView.hourButton }
    private var minuteButton: UIButton { return productivityView.minuteButton }
    private var secondButton: UIButton { return productivityView.secondButton }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return productivityView.timerBadgeCollectionView }
    
    private var timerOptionView: UIView { return productivityView.timerOptionView }
    private var timerOptionViewController: TimerOptionViewController!
    
    private var footerView: Footer { return productivityView.footerView }
    
    // MARK: - properties
    private var isBadgeMoving: Bool = false
    private var timerOptionVisibleSubject: BehaviorRelay = BehaviorRelay(value: false)
    
    var coordinator: ProductivityViewCoordinator
    
    // MARK: - constructor
    init(coordinator: ProductivityViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerBadgeCollectionView.reorderableDelegate = self
        timerBadgeCollectionView.setExtraCell(.add) { [unowned self] timers, cellType in
            switch cellType {
            case .add:
                if timers.count < self.MAX_TIMER_COUNT {
                    return true
                }
                return false
            default:
                return false
            }
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
        timerBadgeCollectionView.addGestureRecognizer(longPressGesture)
        
        // Add timer option view controller
        if let timerOptionNavigationController = coordinator.get(for: .timerOption) as? UINavigationController,
            let timerOptionViewController = timerOptionNavigationController.viewControllers.first as? TimerOptionViewController {
            addChild(timerOptionNavigationController, in: timerOptionView)
            self.timerOptionViewController = timerOptionViewController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Add footer view when view did appear because footer view should remove after will appear due to animation (add view)
        addFooterView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove footer view when view controller disappeared
        showFooterView(isShow: false) {
            self.footerView.removeFromSuperview()
        }
    }
    
    // MARK: - bind
    override func bind() {
        rx.viewDidAppear // For get super view controller (view
            .take(1)
            .subscribe(onNext: { [unowned self] in
                // Bind navigation controller event & tab bar controller event
                self.navigationController?.rx.didShow
                    .skip(1) // Skip until did finished drawing of tab bar controller
                    .filter { [unowned self] in
                        ($0.viewController as? UITabBarController)?.selectedViewController == self
                    }
                    .subscribe(onNext: { [unowned self] viewController, animated in
                        self.showFooterView(isShow: self.reactor?.currentState.canTimeSetStart ?? false)
                    })
                    .disposed(by: self.disposeBag)
                
                self.tabBarController?.rx.didSelect
                    .filter { [unowned self] in
                        $0 == self
                    }
                    .subscribe(onNext: { [unowned self] viewController in
                        self.showFooterView(isShow: self.reactor?.currentState.canTimeSetStart ?? false)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: ProductivityViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .do(onNext: { [weak self] _ in self?.timerOptionVisibleSubject.accept(false) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Timer option view visible
        timerOptionVisibleSubject
            .distinctUntilChanged()
            .map { !$0 }
            .do(onNext: { [weak self] in
                if $0 {
                    self?.timerOptionViewController.navigationController?.popViewController(animated: false)
                    self?.view.endEditing(true)
                }
            })
            .bind(to: timerOptionView.rx.isHidden, timerBadgeCollectionView.rx.isScrollEnabled)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        timerClearButton.rx.tap
            .do(onNext: { [weak self] _ in self?.timerOptionVisibleSubject.accept(false) })
            .map { Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        keyPadView.rx.keyPadTap
            .filter { $0 != .cancel }
            .map { [unowned self] in self.convertKeyToTime(key: $0) }
            .map { Reactor.Action.tapKeyPad($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .filter { $0 == .cancel }
            .subscribe(onNext: { [weak self] _ in self?.showDeleteTimeSetWarningAlert() })
            .disposed(by: disposeBag)
        
        productivityView.rx.timeKeyTap
            .map { Reactor.Action.tapTime($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeSelected
            .do(onNext: { [weak self] in
                self?.scrollToBadgeIfCan(at: $0.0, cellType: $0.1)
                self?.setVisibleOfTimerOptionView(oldIndexPath: reactor.currentState.selectedIndexPath, newIndexPath: $0.0)
            })
            .map { [unowned self] in self.selectBadge(at: $0.0, cellType: $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeMoved
            .map { Reactor.Action.moveTimer(at: $0.0, to: $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerOptionViewController.rx.alarmApplyAll
            .map { Reactor.Action.applyAlarm($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerOptionViewController.rx.delete
            .do(onNext: { [weak self] _ in self?.timerOptionVisibleSubject.accept(false) })
            .map { Reactor.Action.deleteTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        footerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.footerActionHandler(index: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.time }
            .distinctUntilChanged()
            .map { $0 > 0 ? String($0) : "" }
            .bind(to: timerInputLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.time > 0 || $0.canTimeSetStart }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: timeButtonStackView.rx.isHidden, keyPadView.cancelButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Time info view hidden
        reactor.state
            .map { $0.time > 0 || !$0.canTimeSetStart }
            .distinctUntilChanged()
            .bind(to: timeInfoView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Timer update
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
            .bind(to: timerInputView.rx.timer)
            .disposed(by: disposeBag)
        
        // Sum of timers
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { [weak self] in
                self?.getTimeSetInfoString(title: "time_set_sum_of_all_timers_title".localized,
                                           info: String(format: "time_set_sum_of_all_timers_format".localized, $0.0, $0.1, $0.2))
            }
            .bind(to: sumOfTimersLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // End of time set
        Observable.combineLatest(
            reactor.state
                .map { $0.sumOfTimers }
                .distinctUntilChanged(),
            Observable<Int>.timer(.seconds(0), period: RxTimeInterval.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        )
            .map { Date().addingTimeInterval($0.0) }
            .map { [weak self] in
                self?.getTimeSetInfoString(title: "time_set_expected_time_title".localized,
                                           info: getDateString(format: "time_set_expected_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)))
            }
            .bind(to: endOfTimeSetLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Time buttons
        reactor.state
            .map { $0.selectableTime }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.activateTimeKey($0) })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.canTimeSetStart }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.updateViewStateFromCanTimeSetStart($0) })
            .disposed(by: disposeBag)
        
        // Timer badge view
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.timers }
            .bind(to: timerBadgeCollectionView.rx.items)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { [weak self] _ in !(self?.isBadgeMoving ?? false) }
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in
                self?.timerBadgeCollectionView.scrollToBadge(at: $0, animated: true)
                self?.timerOptionVisibleSubject.accept(false)
            })
            .bind(to: timerBadgeCollectionView.rx.selected)
            .disposed(by: disposeBag)
        
        // Timer option view
        reactor.state
            .map { $0.timers[$0.selectedIndexPath.row] }
            .distinctUntilChanged { $0 === $1 }
            .bind(to: timerOptionViewController.rx.timer)
            .disposed(by: disposeBag)
        
        // Alert
        reactor.state
            .map { $0.alertMessage }
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [weak self] in self?.showAlert(message: $0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    /// Scroll badge view if needed by time set action
    private func scrollToBadgeIfCan(at indexPath: IndexPath, cellType: TimerBadgeCellType) {
        switch cellType {
        case .add:
            break
        default:
            timerBadgeCollectionView.scrollToBadge(at: indexPath, animated: true)
        }
    }
    
    /// Convert number key pad input to time value
    private func convertKeyToTime(key: KeyPad.Key) -> Int {
        guard var text = timerInputLabel.text else { return 0 }
        
        if key == .back {
            guard !text.isEmpty else { return 0 }
            text.removeLast()
        } else {
            text.append(String(key.rawValue))
        }
        
        return Int(text) ?? 0
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
    
    /// Toggle timer option view visible state
    private func setVisibleOfTimerOptionView(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        if oldIndexPath == newIndexPath {
            timerOptionVisibleSubject.accept(!timerOptionVisibleSubject.value)
        } else {
            timerOptionVisibleSubject.accept(false)
        }
    }
    
    /// Convert badge select event to reactor action
    private func selectBadge(at indexPath: IndexPath, cellType: TimerBadgeCellType) -> ProductivityViewReactor.Action {
        switch cellType {
        case .add:
            return Reactor.Action.addTimer
        default:
            return Reactor.Action.selectTimer(at: indexPath)
        }
    }
    
    /// Activate only selectable time key buttons
    private func activateTimeKey(_ time: ProductivityViewReactor.Time) {
        // Disable all key
        hourButton.isEnabled = false
        minuteButton.isEnabled = false
        secondButton.isEnabled = false
        
        // Enable selectable key
        switch time {
        case .hour:
            hourButton.isEnabled = true
            fallthrough
        case .minute:
            minuteButton.isEnabled = true
            fallthrough
        case .second:
            secondButton.isEnabled = true
        }
    }
    
    /// Show/Hide view according to `canTimeSetStart` value
    private func updateViewStateFromCanTimeSetStart(_ canTimeSetStart: Bool) {
        // Prevent tab bar swipe gesture
        if let tabBarController = tabBarController as? MainViewController {
            tabBarController.swipeEnable = !canTimeSetStart
        }
        
        // Show created timers
        timerBadgeCollectionView.isHidden = !canTimeSetStart
        // Show timer option footer view
        showFooterView(isShow: canTimeSetStart)
    }
    
    /// Show popup alert about warning to delete time set
    private func showDeleteTimeSetWarningAlert() {
        guard let reactor = reactor else { return }
        
        let alert = AlertBuilder(title: "alert_warning_delete_time_set_title".localized,
                                 message: "alert_warning_delete_time_set_description".localized)
            .addAction(title: "alert_button_cancel".localized, style: .cancel)
            .addAction(title: "alert_button_yes".localized, style: .destructive, handler: { _ in
                reactor.action.onNext(.clearTimeSet)
            })
            .build()
        // Present warning alert view controller
        present(alert, animated: true)
    }
    
    /// Show popup alert
    private func showAlert(message: String) {
        let alert = AlertBuilder(message: message).build()
        // Alert view controller dismiss after 1 seconds
        alert.rx.viewDidLoad
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak alert] in alert?.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        // Present alert view controller
        present(alert, animated: true)
    }
    
    private func headerActionHandler(type: CommonHeader.ButtonType) {
        // TODO: Present
    }
    
    private func footerActionHandler(index: Int) {
        guard let reactor = reactor else { return }
        
        if index == FOOTER_BUTTON_SAVE {
            // Save -> Present time set save =
            _ = coordinator.present(for: .timeSetSave(reactor.timeSetInfo))
        } else if index == FOOTER_BUTTON_START {
            // Confirm -> Present time set start
            // TODO: Present time set start
        }
    }
    
    /// Add footer view into tab bar controller's view to show top of the tab bar hierarchy
    private func addFooterView() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.view.addSubview(footerView)
        
        let tabBar = tabBarController.tabBar
        var frame = tabBar.frame
        
        frame.size.height = tabBar.bounds.height + 10.adjust()
        // Positioning out of screen
        frame.origin.y += frame.height
        footerView.frame = frame
    }
    
    /// Show footer view (save & add & start)
    private func showFooterView(isShow: Bool, completion: (() -> Void)? = nil) {
        guard let tabBar = tabBarController?.tabBar, footerView.superview != nil else { return }
        
        var frame = footerView.frame
        frame.origin.y = isShow ? tabBar.frame.maxY - frame.height : tabBar.frame.minY + tabBar.frame.height
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
            self.footerView.frame = frame
        })
        
        animator.addCompletion({ position in
            if position == .end {
                completion?()
            }
        })
        
        animator.startAnimation()
    }
    
    // MARK: - selector
    @objc private func longPressHandler(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: timerBadgeCollectionView.superview)
        
        switch gesture.state {
        case .began:
            isBadgeMoving = true
            timerOptionVisibleSubject.accept(false)
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

extension ProductivityViewController: JSReorderableCollectionViewDelegate {
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reactor = reactor, indexPath.row < reactor.currentState.timers.count else { return false }
        return true
    }
    
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willSnapshot cell: UICollectionViewCell, at point: CGPoint) -> UIView {
        guard let badge = cell as? TimerBadgeCollectionViewCell else { return cell.snapshotView(afterScreenUpdates: true)! }
        
        let originOptionIsHidden = badge.optionButton.isHidden
        let originIndexIsHidden = badge.indexLabel.isHidden
        
        badge.optionButton.isHidden = true
        badge.indexLabel.isHidden = true
        
        let snapshot = badge.snapshotView(afterScreenUpdates: true)
        badge.optionButton.isHidden = originOptionIsHidden
        badge.indexLabel.isHidden = originIndexIsHidden
        
        return snapshot!
    }
}
