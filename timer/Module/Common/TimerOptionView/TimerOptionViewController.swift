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
    
    // MARK: - properties
    var coordinator: TimerOptionViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimerOptionViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimerOptionView()
    }
    
    // MARK: - bine
    func bind(reactor: TimerOptionViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        commentTextView.rx.text
            .orEmpty
            .map { Reactor.Action.updateComment($0) }
            .bind(to: reactor.action)
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
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Comment length
        reactor.state
            .map { $0.comment }
            .map { $0.lengthOfBytes(using: .utf16) }
            .distinctUntilChanged()
            .map { String(format: "timer_comment_bytes_format".localized, $0, TimerOptionViewReactor.MAX_COMMENT_LENGTH) }
            .bind(to: commentLengthLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Alarm
        reactor.state
            .map { $0.alarm }
            .distinctUntilChanged()
            .bind(to: alarmNameLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose()
    }
}

extension Reactive where Base: TimerOptionViewController {
    // MARK: - binder
    var timer: Binder<TimerInfo> {
        return Binder(base.self) { _, timer in
            guard let reactor = self.base.reactor else { return }
            
            Observable.just(timer)
                .map { Base.Reactor.Action.updateTimer($0) }
                .bind(to: reactor.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    var title: Binder<String> {
        return Binder(base.self) { _, title in
            guard let reactor = self.base.reactor else { return }
            
            Observable.just(title)
                .map { Base.Reactor.Action.updateTitle($0) }
                .bind(to: reactor.action)
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
