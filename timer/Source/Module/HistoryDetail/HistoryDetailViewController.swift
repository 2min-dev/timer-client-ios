//
//  HistoryDetailViewController.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class HistoryDetailViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - constants
    private let MAX_MEMO_LENGTH: Int = 1000
    
    // MARK: - view properties
    private var historyDetailView: HistoryDetailView { view as! HistoryDetailView }
    
    override var headerView: CommonHeader { historyDetailView.headerView }
    
    private var titleLabel: UILabel { historyDetailView.titleLabel }
    private var runningTimeLable: UILabel { historyDetailView.runningTimeLabel }
    private var dateLabel: UILabel { historyDetailView.dateLabel }
    private var extraTimeLabel: UILabel { historyDetailView.extraTimeLabel }
    private var repeatCountLabel: UILabel { historyDetailView.repeatCountLabel }
    
    private var memoTextView: UITextView { historyDetailView.memoTextView }
    private var memoHintLabel: UILabel { historyDetailView.memoHintLabel }
    private var memoExcessLabel: UILabel { historyDetailView.memoExcessLabel }
    private var memoLengthLabel: UILabel { historyDetailView.memoLengthLabel }
    
    private var timerBadgeCollectionView: TimerBadgeCollectionView { historyDetailView.timerBadgeCollectionView }
    
    private var saveButton: FooterButton { historyDetailView.saveButton }
    private var startButton: FooterButton { historyDetailView.startButton }
    
    private var scrollView: UIScrollView { historyDetailView.scrollView }
    
    // MARK: - properties
    var coordinator: HistoryDetailViewCoordinator
    
    private var bubbleAlert: BubbleAlert? {
        didSet {
            timerBadgeCollectionView.isScrollEnabled = bubbleAlert == nil
            guard let alert = bubbleAlert else { return }
            // Bind view event
            bind(alert: alert)
            
            // Set constraint of alert
            scrollView.addAutolayoutSubview(alert)
            alert.snp.makeConstraints { make in
                make.leading.equalTo(timerBadgeCollectionView).inset(60.adjust())
                make.bottom.equalTo(timerBadgeCollectionView.snp.top).inset(-3.adjust())
            }
        }
    }
    
    // MARK: - constructor
    init(coordinator: HistoryDetailViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = HistoryDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        scrollView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    // MARK: - bine
    func bind(reactor: HistoryDetailViewReactor) {
        // MARK: action
        rx.viewWillDisappear
            .map { Reactor.Action.saveHistory }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .map { !$0!.isEmpty }
            .bind(to: memoHintLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .map { ($0, $0.lengthOfBytes(using: .euc_kr)) }
            .filter { [weak self] in $0.1 > (self?.MAX_MEMO_LENGTH ?? 0) }
            .map { String($0.0.dropLast()) }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text
            .orEmpty
            .skip(1)
            .compactMap { Reactor.Action.updateMemo($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.saveTimeSet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let timeSetItem = reactor.timeSetItem else { return }
                _ = self?.coordinator.present(for: .timeSetProcess(timeSetItem), animated: true)
            })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Tile
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Running time
        reactor.state
            .map { $0.runningTime }
            .distinctUntilChanged()
            .map { getTime(interval: $0) }
            .map { String(format: "time_set_time_format".localized, $0.0, $0.1, $0.2) }
            .bind(to: runningTimeLable.rx.text)
            .disposed(by: disposeBag)
        
        // Date
        Observable.combineLatest(
            reactor.state
                .map { $0.startDate }
                .distinctUntilChanged(),
            reactor.state
                .map { $0.endDate }
                .distinctUntilChanged())
            .map { [weak self] in self?.makeDateAttributedString(startDate: $0, endDate: $1) }
            .bind(to: dateLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        // Extra time
        reactor.state
            .map { $0.extraTime / Constants.Time.minute }
            .distinctUntilChanged()
            .map { String(format: "history_extra_time_format".localized, Int($0)) }
            .bind(to: extraTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Repeat count
        reactor.state
            .map { $0.repeatCount }
            .distinctUntilChanged()
            .map { String(format: "history_repeat_count_format".localized, $0) }
            .bind(to: repeatCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Memo
        reactor.state
            .map { $0.memo }
            .filter { [weak self] in self?.memoTextView.text != $0 }
            .bind(to: memoTextView.rx.text)
            .disposed(by: disposeBag)
        
        // Memo length
        let lengthOfBytes = reactor.state
            .map { $0.memo }
            .map { $0.lengthOfBytes(using: .euc_kr) }
            .distinctUntilChanged()
            .share(replay: 1)
        
        let isMemoExceeded = lengthOfBytes
            .map { [weak self] in $0 >= self?.MAX_MEMO_LENGTH ?? 0 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // Length text
        Observable.combineLatest(lengthOfBytes, isMemoExceeded)
            .compactMap { [weak self] in self?.makeMemoLengthAttributedString(length: $0, isExcess: $1) }
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
        
        // Timer badge
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: timerBadgeCollectionView.rx.items(dataSource: timerBadgeCollectionView._dataSource))
            .disposed(by: disposeBag)
        
        // End state
        reactor.state
            .map { $0.endState }
            .distinctUntilChanged()
            .withLatestFrom(
                Observable.zip(
                    reactor.state.map { $0.endIndex },
                    reactor.state.map { $0.remainedTime },
                    reactor.state.map { $0.overtime })) { ($0, $1.0, $1.1, $1.2) }
            .subscribe(onNext: { [weak self] in self?.showTimeSetEndStateAlert($0, index: $1, remainedTime: $2, overtime: $3) })
            .disposed(by: disposeBag)
        
        // Time set can save
        reactor.state
            .map { $0.canTimeSetSave }
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Time set did saved
        reactor.state
            .map { $0.didTimeSetSaved }
            .distinctUntilChanged()
            .compactMap { $0.value }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.showTimeSetSavedToast() })
            .disposed(by: disposeBag)
    }
    
    func bind(alert: BubbleAlert) {
        Observable.merge(
            alert.rx.cancel.asObservable(),
            alert.rx.confirm.asObservable())
            .subscribe(onNext: {[weak self] in self?.bubbleAlert = nil })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: Header.Action) {
        switch action {
        case .back:
            coordinator.present(for: .dismiss, animated: true)
            
        default:
            break
        }
    }
    
    // MARK: - state method
    /// Show time set end state alert
    private func showTimeSetEndStateAlert(_ endState: History.EndState, index: Int, remainedTime: TimeInterval, overtime: TimeInterval) {
        switch endState {
        case .cancel:
            showTimeSetCancelAlert(index: index, remained: remainedTime)
            
        case .overtime:
            showTimeSetOvertimeAlert(overtime: overtime)
            
        default:
            break
        }
    }
    
    /// Make memo length attributed string
    private func makeMemoLengthAttributedString(length: Int, isExcess: Bool) -> NSAttributedString {
        let lengthString = String(format: "time_set_memo_bytes_format".localized, length, MAX_MEMO_LENGTH)
        let attributedString = NSMutableAttributedString(string: lengthString)
        
        if isExcess {
            // Highlight length text
            let range = NSString(string: lengthString).range(of: String(length))
            attributedString.addAttribute(.foregroundColor, value: Constants.Color.carnation, range: range)
        }
        
        return attributedString
    }
    
    /// Make time set history date attributed string
    private func makeDateAttributedString(startDate: Date, endDate: Date) -> NSAttributedString {
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
        let attributes: [NSAttributedString.Key: Any] = [.kern: -0.45]
        
        return NSAttributedString(string: dateString, attributes: attributes)
    }
    
    /// Sohw time set saved toast
    private func showTimeSetSavedToast() {
        guard let timeSetItem = reactor?.timeSetItem else { return }
        Toast(content: "toast_time_set_saved_title".localized,
              task: ToastTask(title: "toast_task_edit_title".localized) { [weak self] in
                _ = self?.coordinator.present(for: .timeSetEdit(timeSetItem), animated: true)
        }).show(animated: true, withDuration: 3)
    }
    
    // MARK: - private method
    /// Show time set canceled alert
    private func showTimeSetCancelAlert(index: Int, remained time: TimeInterval) {
        let (hour, minute, second) = getTime(interval: time)
        let timeString = String(format: "time_set_time_format".localized, hour, minute, second)
        
        // Create bubble alert view
        bubbleAlert = BubbleAlert(text: String(format: "history_alert_time_set_cancel_format".localized, index + 1, timeString))
    }
    
    /// Show time set overtime alert
    private func showTimeSetOvertimeAlert(overtime: TimeInterval) {
        let (hour, minute, second) = getTime(interval: overtime)
        let timeString = String(format: "time_set_time_format".localized, hour, minute, second)
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.adjust()
        
        // Create attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Font.Bold.withSize(12.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .kern: -0.36,
            .paragraphStyle: paragraphStyle
        ]
        
        let text = String(format: "history_alert_time_set_overtime_format".localized, timeString)
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        // Highlight time string
        attributedString.addAttributes([.foregroundColor: Constants.Color.carnation], range: (text as NSString).range(of: timeString))
        
        // Create alert & binding
        bubbleAlert = BubbleAlert(attributedText: attributedString)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        Logger.verbose()
    }
}
