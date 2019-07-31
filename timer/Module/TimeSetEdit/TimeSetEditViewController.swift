//
//  TimeSetEditViewController.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetEditViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetEditView: TimeSetEditView { return view as! TimeSetEditView }
    
    private var titleTextField: UITextField { return timeSetEditView.titleTextField }
    private var titleHintLabel: UILabel { return timeSetEditView.titleHintLabel }
    
    private var sumOfTimersLabel: UILabel { return timeSetEditView.sumOfTimersLabel}
    private var endOfTimerLabel: UILabel { return timeSetEditView.endOfTimerLabel }
    
    private var startAfterSaveCheckBox: CheckBox { return timeSetEditView.startAfterSaveCheckBox }
    
    private var timerOptionView: UIView { return timeSetEditView.timerOptionView }
    private var timerOptionViewController: TimerOptionViewController!
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetEditView.timerBadgeCollectionView }
    
    private var footerView: UIView { return timeSetEditView.footerView }
    
    // MARK: - properties
    var coordinator: TimeSetEditViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetEditViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetEditView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        
        // Add timer option view controller
        if let timerOptionNavigationController = coordinator.get(for: .timerOption) as? UINavigationController,
            let timerOptionViewController = timerOptionNavigationController.viewControllers.first as? TimerOptionViewController {
            addChild(timerOptionNavigationController, in: timerOptionView)
            self.timerOptionViewController = timerOptionViewController
        }
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetEditViewReactor) {
        // MARK: action
        
        // MARK: state
        // Title of time set
        reactor.state
            .map { $0.title }
            .bind(to: titleHintLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Sum of timers
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "전체 %02d:%02d:%02d", $0.0, $0.1, $0.2) }
            .bind(to: sumOfTimersLabel.rx.text)
            .disposed(by: disposeBag)
        
        // End of time set
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { Date().addingTimeInterval($0) }
            .map { getDateString(format: "종료 H:mm a", date: $0, locale: Locale(identifier: Constants.Locale.USA)) }
            .bind(to: endOfTimerLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Start after save check box
        reactor.state
            .map { $0.isStartAfterSave }
            .distinctUntilChanged()
            .bind(to: startAfterSaveCheckBox.rx.isChecked)
            .disposed(by: disposeBag)
        
        // Timer badge view
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.timers }
            .bind(to: timerBadgeCollectionView.rx.items)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedIndexPath }
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0) })
            .bind(to: timerBadgeCollectionView.rx.selected)
            .disposed(by: disposeBag)
        
        // Timer option view
        reactor.state
            .map { $0.timers[$0.selectedIndexPath.row] }
            .distinctUntilChanged { $0 === $1 }
            .bind(to: timerOptionViewController.rx.timer)
            .disposed(by: disposeBag)
    
    }
    
    // MARK: - priate method
    
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
