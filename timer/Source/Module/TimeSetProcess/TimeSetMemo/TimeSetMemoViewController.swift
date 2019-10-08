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

class TimeSetMemoViewController: BaseHeaderViewController, View {
    // MARK: - constants
    private let MAX_MEMO_LENGTH: Int = 1000
    
    // MARK: - view properties
    private var timeSetMemoView: TimeSetMemoView { return view as! TimeSetMemoView }
    
    override var headerView: CommonHeader { return timeSetMemoView.headerView }
    
    private var memoTextView: UITextView { return timeSetMemoView.memoTextView }
    private var memoHintLabel: UILabel { return timeSetMemoView.memoHintLabel }
    private var memoExcessLabel: UILabel { return timeSetMemoView.memoExcessLabel }
    private var memoLengthLabel: UILabel { return timeSetMemoView.memoLengthLabel }
    
    // MARK: - properties
    var coordinator: TimeSetMemoViewCoordinator
    
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
    
    // MARK: - bine
    func bind(reactor: TimeSetMemoViewReactor) {
        // MARK: action
        rx.viewDidAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.memoTextView.becomeFirstResponder() })
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .map { ($0, $0.lengthOfBytes(using: .utf16)) }
            .filter { [weak self] in $0.1 > (self?.MAX_MEMO_LENGTH ?? 0) }
            .map { String($0.0.dropLast()) }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
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
        
        // Memo length
        let lengthOfBytes = reactor.state
            .map { $0.memo }
            .map { $0.lengthOfBytes(using: .utf16) }
            .distinctUntilChanged()
            .share(replay: 1)
        
        let isMemoExceeded = lengthOfBytes
            .map { [weak self] in $0 >= self?.MAX_MEMO_LENGTH ?? 0 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // Length text
        Observable.combineLatest(lengthOfBytes, isMemoExceeded)
            .compactMap { [weak self] in self?.getMemoLengthAttributedString(length: $0, isExcess: $1) }
            .bind(to: memoLengthLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Exceeded info
        isMemoExceeded
            .map { !$0 }
            .bind(to: memoExcessLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        isMemoExceeded
            .filter { $0 }
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .bind(to: memoExcessLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    override func handleHeaderAction(_ action: CommonHeader.Action) {
        super.handleHeaderAction(action)
        
        switch action {
        case .close:
            dismissOrPopViewController(animated: true)
            
        default:
            break
        }
    }
    
    // MARK: - state method
    /// Get memo length attributed string
    private func getMemoLengthAttributedString(length: Int, isExcess: Bool) -> NSAttributedString {
        let lengthString = String(format: "time_set_memo_bytes_format".localized, length, MAX_MEMO_LENGTH)
        let attributedString = NSMutableAttributedString(string: lengthString)
        
        if isExcess {
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
