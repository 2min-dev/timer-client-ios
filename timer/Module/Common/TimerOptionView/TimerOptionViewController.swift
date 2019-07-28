//
//  TimerOptionViewController.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimerOptionViewController: BaseViewController, View {
    // MARK: - view properties
    private var timerOptionView: TimerOptionView { return view as! TimerOptionView }
    
    private var commentTextView: UITextView { return timerOptionView.commentTextView }
    private var commentLengthLabel: UILabel { return timerOptionView.commentLengthLabel }
    private var commentHintLabel: UILabel { return timerOptionView.commentHintLabel }
    
    private var alarmNameLabel: UILabel { return timerOptionView.alarmNameLabel }
    fileprivate var alarmApplyAllButton: UIButton { return timerOptionView.alarmApplyAllButton }
    private var alarmChangeButton: UIButton { return timerOptionView.alarmChangeButton }
    
    private var titleLabel: UILabel { return timerOptionView.titleLabel }
    fileprivate var deleteButton: UIButton { return timerOptionView.deleteButton }
    
    private var alarmChangeViewController: AlarmChangeViewController!
    
    // MARK: - properties
    var coordinator: TimerOptionViewCoordinator!
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimerOptionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    func bind(reactor: TimerOptionViewReactor) {
        // MARK: action
        commentTextView.rx.text
            .orEmpty
            .map { Reactor.Action.updateComment($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        alarmChangeButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.navigateToAlarmChange() })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Comment
        reactor.state
            .map { $0.comment }
            .filter { self.commentTextView.text != $0 }
            .debug()
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Comment hint
        reactor.state
            .map { !$0.comment.isEmpty }
            .distinctUntilChanged()
            .bind(to: commentHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Comment length
        reactor.state
            .map { $0.comment }
            .map { $0.lengthOfBytes(using: .utf8) }
            .map { String(format: "timer_option_comment_bytes".localized, $0, TimerOptionViewReactor.MAX_COMMENT_LENGTH) }
            .distinctUntilChanged()
            .bind(to: commentLengthLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Alarm
        reactor.state
            .map { $0.alarm }
            .distinctUntilChanged()
            .bind(to: alarmNameLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - priate method
    private func navigateToAlarmChange() {
        guard let reactor = reactor,
            let timerInfo = reactor.timerInfo else { return }
        
        view.endEditing(true)
        if let viewController = coordinator.present(for: .alarmChange(timerInfo.alarm)) as? AlarmChangeViewController {
            viewController.rx.alarmSelected
                .map { Reactor.Action.updateAlarm($0) }
                .bind(to: reactor.action)
                .disposed(by: viewController.disposeBag)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension Reactive where Base: TimerOptionViewController {
    // MARK: - binder
    var timer: Binder<TimerInfo> {
        return Binder(base.self) { _, timerInfo in
            Observable.just(timerInfo)
                .map { Base.Reactor.Action.changeTimer($0) }
                .bind(to: self.base.reactor!.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    // MARK: - control event
    var alarmApplyAll: ControlEvent<String> {
        let source = base.alarmApplyAllButton.rx.tap
            .map { self.base.reactor!.currentState.alarm }
        return ControlEvent(events: source)
    }
    
    var delete: ControlEvent<Void> {
        let source = base.deleteButton.rx.tap
        return ControlEvent(events: source)
    }
}
