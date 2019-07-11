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

class ProductivityViewController: BaseViewController, View {
    // MARK: - view properties
    private var productivityView: ProductivityView { return self.view as! ProductivityView }
    private var contentView: UIView { return productivityView.contentView }
    
    private var footerStackView: UIStackView { return productivityView.footerStackView }
    private var footerView: UIView { return productivityView.footerView }
    
    private var timerInputView: UIView { return productivityView.timerInputView }
    private var timerLabel: UILabel { return productivityView.timerLabel }
    private var timerClearButton: UIButton { return productivityView.timerClearButton }
    
    private var sumOfTimersLabel: UILabel { return productivityView.sumOfTimersLabel }
    private var endOfTimerLabel: UILabel { return productivityView.endOfTimerLabel }
    private var timerInputLabel: UILabel { return productivityView.timerInputLabel }
    
    private var keyPadView: KeyPad { return productivityView.keyPadView }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return productivityView.timerBadgeCollectionView }
    
    private var saveButton: UIButton { return productivityView.saveButton }
    private var addButton: UIButton { return productivityView.addButton }
    
    // MARK: - constants
    private let MAX_TIMER_COUNT: Int = 10
    private let MAX_TIME_INPUT_COUNT: Int = 3
    
    // MARK: - properties
    var coordinator: ProductivityViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        timerBadgeCollectionView.anchorPoint = TimerBadgeCollectionView.centerAnchor
        timerBadgeCollectionView.setExtraCell(.add) { timers, cellType in
            switch cellType {
            case .add:
                if timers.count < 10 {
                    return true
                }
                return false
            default:
                return false
            }
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
                        self.showFooterView(isShow: self.reactor?.currentState.canStart ?? false)
                    })
                    .disposed(by: self.disposeBag)
                
                self.tabBarController?.rx.didSelect
                    .filter { [unowned self] in
                        $0 == self
                    }
                    .subscribe(onNext: { [unowned self] viewController in
                        self.showFooterView(isShow: self.reactor?.currentState.canStart ?? false)
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
        
        keyPadView.rx.keyPadTap
            .filter { [unowned self] in self.isValidKey($0) }
            .map { [unowned self] in self.makeTimeWithKey($0) }
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
        
        addButton.rx.tap
            .map { Reactor.Action.addTimer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        timerBadgeCollectionView.rx.badgeSelected
            .map { badge -> Reactor.Action in
                switch badge.1 {
                case .add:
                    return Reactor.Action.addTimer
                default:
                    return Reactor.Action.timerSelected(badge.0)
                }
            }
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
            .map { $0.timer }
            .distinctUntilChanged()
            .bind(to: timerBadgeCollectionView.rx.timer)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timer }
            .distinctUntilChanged()
            .map {
                guard $0 > 0 else { return "0" }
                
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .full
                formatter.allowedUnits = [.hour, .minute, .second]
                return formatter.string(from: $0) ?? ""
            }
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.timer }
            .map { $0 > 0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] hasTime in
                guard let `self` = self else { return }
                
                // Show timer clear button
                self.timerClearButton.isHidden = !hasTime
                
                let borderColor = hasTime ? Constants.Color.black.cgColor : Constants.Color.gray.cgColor
                let animation = CABasicAnimation(keyPath: "borderColor")
                animation.fromValue = self.timerInputView.layer.borderColor
                animation.toValue = borderColor
                animation.duration = 0.5
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                
                self.timerInputView.layer.borderColor = borderColor
                self.timerInputView.layer.add(animation, forKey: "borderColor")
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { Int($0.sumOfTimers) }
            .distinctUntilChanged()
            .map {
                let seconds = $0 % 60
                let minutes = ($0 / 60) % 60
                let hours = $0 / 3600
                
                return String.init(format: "전체 %03d:%02d:%02d", hours, minutes, seconds)
            }
            .bind(to: sumOfTimersLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.sumOfTimers }
            .map {
                var current = Date()
                current.addTimeInterval($0)
                return getDateString(format: "종료 H:mm a", date: current, locale: Locale(identifier: Constants.Locale.USA))
            }
            .bind(to: endOfTimerLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.canStart }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                // Prevent tab bar swipe gesture
                if let tabBarController = self.tabBarController as? MainViewController {
                    tabBarController.swipeEnable = !$0
                }
                
                // Show timer info
                self.sumOfTimersLabel.isHidden = !$0
                self.endOfTimerLabel.isHidden = !$0
                
                // Show created timers
                self.timerBadgeCollectionView.isHidden = !$0
                // Show timer option footer view
                self.showFooterView(isShow: $0)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldReloadSection }
            .map { $0.timers }
            .bind(to: timerBadgeCollectionView.rx.items)
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func isValidKey(_ key: KeyPad.Key) -> Bool {
        guard key != .cancel else { return false }
        guard let text = timerInputLabel.text else { return false }
        
        switch key {
        case .back:
            return !text.isEmpty
        default:
            return text.count < MAX_TIME_INPUT_COUNT
        }
    }
    
    private func makeTimeWithKey(_ key: KeyPad.Key) -> Int {
        guard var text = timerInputLabel.text else { return 0 }
        
        switch key {
        case .back:
            text.removeLast()
        default:
            text.append(String(key.rawValue))
        }
        
        return Int(text) ?? 0
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
    
    deinit {
        Logger.verbose()
    }
}
