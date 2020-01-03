//
//  TimeSetMemoViewController.swift
//  timer
//
//  Created by JSilver on 25/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class TimeSetMemoViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - constants
    private static let MAX_MEMO_LENGTH: Int = 1000
    
    // MARK: - view properties
    private var timeSetMemoView: TimeSetMemoView { return view as! TimeSetMemoView }
    
    override var headerView: CommonHeader { return timeSetMemoView.headerView }
    
    private var memoTextView: UITextView { return timeSetMemoView.memoTextView }
    private var memoHintLabel: UILabel { return timeSetMemoView.memoHintLabel }
    private var memoExcessLabel: UILabel { return timeSetMemoView.memoExcessLabel }
    private var memoLengthLabel: UILabel { return timeSetMemoView.memoLengthLabel }
    
    // MARK: - properties
    var coordinator: TimeSetMemoViewCoordinator
    
    var isExceeded: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    // MARK: - constructor
    init(coordinator: TimeSetMemoViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetMemoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .filter { $0.lengthOfBytes(using: .euc_kr) > Self.MAX_MEMO_LENGTH }
            .do(onNext: { [weak self] _ in self?.isExceeded.accept(true) })
            .map { String($0.dropLast()) }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Memo length
        Observable.combineLatest(
            memoTextView.rx.text
                .orEmpty
                .map { $0.lengthOfBytes(using: .euc_kr) }
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
    func bind(reactor: TimeSetMemoViewReactor) {
        // MARK: action
        rx.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.memoTextView.becomeFirstResponder() })
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .skip(1)
            .compactMap { Reactor.Action.updateMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Memo
        reactor.state
            .map { $0.memo }
            .filter { [weak self] in self?.memoTextView.text != $0 }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: CommonHeader.Action) {
        switch action {
        case .close:
            coordinator.present(for: .dismiss, animated: true)
            
        default:
            break
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}

extension Reactive where Base: TimeSetMemoViewController {
    var close: ControlEvent<Void> {
        ControlEvent(events: base.headerView.rx.tap.filter { $0 == .close }.map { _ in })
    }
}
