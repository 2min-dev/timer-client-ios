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
    // MARK: - constants
    private let FOOTER_BUTTON_CANCEL = 0
    private let FOOTER_BUTTON_CONFIRM = 1
    
    // MARK: - view properties
    private var timeSetEditView: TimeSetEditView { return view as! TimeSetEditView }
    
    private var titleTextField: UITextField { return timeSetEditView.titleTextField }
    private var titleClearButton: UIButton { return timeSetEditView.titleClearButton }
    private var titleHintLabel: UILabel { return timeSetEditView.titleHintLabel }
    
    private var sumOfTimersLabel: UILabel { return timeSetEditView.sumOfTimersLabel}
    private var endOfTimerLabel: UILabel { return timeSetEditView.endOfTimerLabel }
    
    private var timerOptionView: UIView { return timeSetEditView.timerOptionView }
    private var timerOptionViewController: TimerOptionViewController!
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { return timeSetEditView.timerBadgeCollectionView }
    
    private var footerView: Footer { return timeSetEditView.footerView }
    
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
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleTextField.rx.text
            .orEmpty
            .skipUntil(rx.viewWillAppear)
            .map { Reactor.Action.updateTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        titleClearButton.rx.tap
            .map { Reactor.Action.clearTitle }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        timerBadgeCollectionView.rx.badgeSelected
            .do(onNext: { [weak self] in self?.timerBadgeCollectionView.scrollToBadge(at: $0.0, animated: true) })
            .map { Reactor.Action.selectTimer(at: $0.0) }
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
            .debug()
            .bind(to: titleTextField.rx.text)
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
        reactor.state
            .map { $0.sumOfTimers }
            .distinctUntilChanged()
            .map { Date().addingTimeInterval($0) }
            .map { [weak self] in
                self?.getTimeSetInfoString(title: "time_set_expected_time_title".localized,
                                           info: getDateString(format: "time_set_expected_time_format".localized, date: $0, locale: Locale(identifier: Constants.Locale.USA)))
            }
            .bind(to: endOfTimerLabel.rx.attributedText)
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
    private func footerActionHandler(index: Int) {
        if index == FOOTER_BUTTON_CANCEL {
            // Cancel -> Pop view controller
            navigationController?.popViewController(animated: true)
        } else if index == FOOTER_BUTTON_CONFIRM {
            // Confirm -> Present time set detail
            // TODO: Present time set detail
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
