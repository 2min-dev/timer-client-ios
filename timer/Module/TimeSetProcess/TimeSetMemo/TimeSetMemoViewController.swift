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

class TimeSetMemoViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetMemoView: TimeSetMemoView { return view as! TimeSetMemoView }
    
    private var titleLabel: UILabel { return timeSetMemoView.titleLabel }
    private var timeLabel: UILabel { return timeSetMemoView.timeLabel }
    
    private var memoTextView: UITextView { return timeSetMemoView.memoTextView }
    private var memoLengthExcessLabel: UILabel { return timeSetMemoView.memoLengthExcessLabel }
    private var memoLengthLabel: UILabel { return timeSetMemoView.memoLengthLabel }
    
    private var cancelButton: FooterButton { return timeSetMemoView.cancelButton }
    private var pauseButton: FooterButton{ return timeSetMemoView.pauseButton }
    private var restartButton: FooterButton { return timeSetMemoView.restartButton }
    
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
        memoTextView.rx.text
            .orEmpty
            .filter { !$0.isEmpty }
            .map { Reactor.Action.updateMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Remained time
        reactor.state
            .map { $0.remainedTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Memo
        reactor.state
            .map { $0.memo }
            .filter { [weak self] in self?.memoTextView.text != $0 }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Memo length
        reactor.state
            .map { $0.memo }
            .map { $0.lengthOfBytes(using: .unicode) }
            .distinctUntilChanged()
            .do(onNext: { [weak self] in self?.memoLengthExcessLabel.isHidden = $0 < TimeSetEndViewReactor.MAX_MEMO_LENGTH })
            .map { String(format: "time_set_memo_bytes_format".localized, $0, TimeSetEndViewReactor.MAX_MEMO_LENGTH) }
            .bind(to: memoLengthLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
