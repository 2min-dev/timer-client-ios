//
//  TimeSetEndViewController.swift
//  timer
//
//  Created by JSilver on 2019/10/09.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetEndViewController: BaseHeaderViewController, View {
    // MARK: - constants
    private static let MAX_MEMO_LENGTH: Int = 1000
    
    // MARK: - view properties
    private var timeSetEndView: TimeSetEndView { return view as! TimeSetEndView }
    
    override var headerView: CommonHeader { return timeSetEndView.headerView }
    
    private var titleLabel: UILabel { return timeSetEndView.titleLabel }
    private var dateLabel: UILabel { return timeSetEndView.dateLabel }
    
    private var memoTextView: UITextView { return timeSetEndView.memoTextView }
    private var memoHintLabel: UILabel { return timeSetEndView.memoHintLabel }
    private var memoExcessLabel: UILabel { return timeSetEndView.memoExcessLabel }
    private var memoLengthLabel: UILabel { return timeSetEndView.memoLengthLabel }
    
    fileprivate var overtimeButton: FooterButton { return timeSetEndView.overtimeButton }
    fileprivate var restartButton: FooterButton { return timeSetEndView.restartButton }
    
    // MARK: - properties
    var coordinator: TimeSetEndViewCoordinator
    
    var isExceeded: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    // MARK: - constructor
    init(coordinator: TimeSetEndViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetEndView()
    }
    
    override func bind() {
        super.bind()
        
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .filter { $0.lengthOfBytes(using: .utf16) > Self.MAX_MEMO_LENGTH }
            .do(onNext: { [weak self] _ in self?.isExceeded.accept(true) })
            .map { String($0.dropLast()) }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Memo length
        Observable.combineLatest(
            memoTextView.rx.text
                .orEmpty
                .map { $0.lengthOfBytes(using: .utf16) }
                .distinctUntilChanged(),
            isExceeded.distinctUntilChanged())
            .compactMap { [weak self] in self?.getMemoLengthAttributedString(length: $0, isExceeded: $1) }
            .bind(to: memoLengthLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Exceeded memo
        isExceeded
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: memoExcessLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        isExceeded
            .filter { $0 }
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .map { !$0 }
            .bind(to: isExceeded)
            .disposed(by: disposeBag)
    }
    
    // MARK: - bine
    func bind(reactor: TimeSetEndViewReactor) {
        // MARK: action
        rx.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.memoTextView.becomeFirstResponder() })
            .disposed(by: disposeBag)
        
        rx.viewWillDisappear
            .map { Reactor.Action.viewWillDisappear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .skip(1)
            .compactMap { Reactor.Action.updateMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        overtimeButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismissOrPopViewController(animated: true) })
            .disposed(by: disposeBag)
        
        restartButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismissOrPopViewController(animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Date
        Observable.combineLatest(
            reactor.state
                .map { $0.startDate }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.endDate }
                .distinctUntilChanged())
            .map { [weak self] in self?.getDateAttributedString(startDate: $0, endDate: $1) }
            .bind(to: dateLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Memo
        reactor.state
            .map { $0.memo }
            .filter { [weak self] in self?.memoTextView.text != $0 }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - state method
    /// Get memo length attributed string
    private func getMemoLengthAttributedString(length: Int, isExceeded: Bool) -> NSAttributedString {
        let lengthString = String(format: "time_set_memo_bytes_format".localized, length, Self.MAX_MEMO_LENGTH)
        let attributedString = NSMutableAttributedString(string: lengthString)
        
        if isExceeded {
            // Highlight length text
            let range = NSString(string: lengthString).range(of: String(length))
            attributedString.addAttribute(.foregroundColor, value: Constants.Color.carnation, range: range)
        }
        
        return attributedString
    }
    
    /// Get date attributed string
    private func getDateAttributedString(startDate: Date, endDate: Date) -> NSAttributedString {
        // Get day of dates
        let startDay = Calendar.current.component(.day, from: startDate)
        let endDay = Calendar.current.component(.day, from: endDate)
        
        // Get date string
        let startDateString = getDateString(format: "history_full_date_format".localized,
                                            date: startDate,
                                            locale: Locale(identifier: Constants.Locale.USA))
        
        let endDateString = getDateString(format: startDay == endDay ? "history_short_date_format".localized : "history_full_date_format".localized,
                                          date: endDate,
                                          locale: Locale(identifier: Constants.Locale.USA))
        
        let dateString = String(format: "%@ - %@", startDateString, endDateString)
        let attributes: [NSAttributedString.Key: Any] = [.kern: -0.3]
        
        return NSAttributedString(string: dateString, attributes: attributes)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}

extension Reactive where Base: TimeSetEndViewController {
    var tapOvertime: ControlEvent<Void> {
        return ControlEvent(events: base.overtimeButton.rx.tap)
    }
    
    var tapRestart: ControlEvent<Void> {
        return ControlEvent(events: base.restartButton.rx.tap)
    }
}
