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
    // MARK: - view properties
    private var productivityView: ProductivityView { return self.view as! ProductivityView }
    private var contentView: UIView { return productivityView.contentView }
    
    private var footerStackView: UIStackView { return productivityView.footerStackView }
    private var footerView: UIView { return productivityView.footerView }
    
    private var timerInputView: UIView { return productivityView.timerInputView }
    private var timerLabel: UILabel { return productivityView.timerLabel }
    private var timerClearButton: UIButton { return productivityView.timerClearButton }
    
    private var timeInfoView: UIView { return productivityView.timeInfoView }
    private var sumOfTimersLabel: UILabel { return productivityView.sumOfTimersLabel }
    private var endOfTimerLabel: UILabel { return productivityView.endOfTimerLabel }
    private var loopButton: UIButton { return productivityView.loopButton }
    private var timerInputLabel: UILabel { return productivityView.timeInputLabel }
    
    private var keyPadView: KeyPad { return productivityView.keyPadView }
    
    private var timeButtonStackView: UIStackView { return productivityView.timeButtonStackView }
    private var hourButton: UIButton { return productivityView.hourButton }
    private var minuteButton: UIButton { return productivityView.minuteButton }
    private var secondButton: UIButton { return productivityView.secondButton }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return productivityView.timerBadgeCollectionView }
    
    private var timerOptionView: UIView { return productivityView.timerOptionView }
    private var timerOptionViewController: TimerOptionViewController!
    
    private var saveButton: UIButton { return productivityView.saveButton }
    
    // MARK: - constants
    private let MAX_TIMER_COUNT: Int = 10
    
    // MARK: - properties
    var coordinator: ProductivityViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        timerBadgeCollectionView.reorderableDelegate = self
        timerBadgeCollectionView.setExtraCell(.add) { timers, cellType in
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
        timerClearButton.rx.tap
            .map { Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loopButton.rx.tap
            .map { Reactor.Action.tapTimeSetLoop }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .map { self.convertKeyToTime(key: $0) }
            .map { Reactor.Action.updateTime($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        keyPadView.rx.keyPadTap
            .filter { $0 == .cancel }
            .map { _ in Reactor.Action.clearTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productivityView.rx.timeKeyTap
            .map { Reactor.Action.tapTimeKey($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeSelected
            .map { self.selectBadge(at: $0.0, cellType: $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timerBadgeCollectionView.rx.badgeMoved
            .map { Reactor.Action.moveTimer(at: $0.0, to: $0.1) }
            .bind(to: reactor.action)
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
            .bind(to: timeButtonStackView.rx.isHidden)
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
            .map { getTime(interval: $0) }
            .map { String(format: "%02d:%02d:%02d", $0.0, $0.1, $0.2) }
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Timer clear button
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
            .map { $0 <= 0 }
            .distinctUntilChanged()
            .bind(to: timerClearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Sum of timers
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "전체 %02d:%02d:%02d", $0.0, $0.1, $0.2) }
            .bind(to: sumOfTimersLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time set loop
        reactor.state
            .map { $0.isTimeSetLoop }
            .distinctUntilChanged()
            .bind(to: loopButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // End of time set
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { Date().addingTimeInterval($0) }
            .map { getDateString(format: "종료 H:mm a", date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimerLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Time buttons
        reactor.state
            .map { $0.maxSelectableTime }
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
            .filter { $0.timeSetAction != .None }
            .map { $0.selectedIndexPath }
            .withLatestFrom(reactor.state.map { $0.timeSetAction }, resultSelector: { ($0, $1) })
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.scrollToBadgeIfNeeded(at: $0.0, action: $0.1) })
            .map { $0.0 }
            .bind(to: timerBadgeCollectionView.rx.selected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.isTimerOptionVisible }
            .distinctUntilChanged()
            .do(onNext: {
                if $0 {
                   self.timerOptionViewController.navigationController?.popViewController(animated: false)
                }
            })
            .bind(to: timerOptionView.rx.isHidden, timerBadgeCollectionView.rx.isScrollEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timers[$0.selectedIndexPath.row] }
            .distinctUntilChanged { $0 === $1 }
            .debug()
            .bind(to: timerOptionViewController.rx.timer)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
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
    
    // Scroll badge view if needed by time set action
    private func scrollToBadgeIfNeeded(at indexPath: IndexPath, action: ProductivityViewReactor.TimeSetAction) {
        switch action {
        case .Select:
            timerBadgeCollectionView.scrollToBadge(at: indexPath)
        default:
            break
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
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            timerBadgeCollectionView.beginInteractiveWithLocation(location)
        case .changed:
            timerBadgeCollectionView.updateInteractiveWithLocation(location)
        default:
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
        
        badge.optionButton.isHidden = true
        badge.indexLabel.isHidden = true
        
        let snapshot = badge.snapshotView(afterScreenUpdates: true)
        badge.optionButton.isHidden = false
        badge.indexLabel.isHidden = false
        
        return snapshot!
    }
}
