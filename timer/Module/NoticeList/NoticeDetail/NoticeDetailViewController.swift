//
//  NoticeDetailViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class NoticeDetailViewController: BaseViewController, View {
    // MARK: - view properties
    private var noticeDetailView: NoticeDetailView { return view as! NoticeDetailView }
    
    private var headerView: CommonHeader { return noticeDetailView.headerView }
    
    private var noticeTextView: UITextView { return noticeDetailView.noticeTextView }
    
    // MARK: - properties
    var coordinator: NoticeDetailViewCoordinator
    
    // MARK: - constructor
    init(coordinator: NoticeDetailViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = NoticeDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    override func bind() {
        noticeTextView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: NoticeDetailViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        // Scroll to top
        noticeTextView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] _ in self?.noticeTextView.setContentOffset(.zero, animated: false) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: headerView.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.date }
            .distinctUntilChanged()
            .map { getDateString(format: "yy.MM.dd", date: $0) }
            .map { NSAttributedString(string: $0) }
            .bind(to: headerView.rx.additionalText)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.content }
            .distinctUntilChanged()
            .map { [weak self] in self?.getNoticeAttributedText($0) }
            .bind(to: noticeTextView.rx.attributedText)
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    /// Handle header button tap action according to button type
    private func headerActionHandler(type: CommonHeader.ButtonType) {
        switch type {
        case .back:
            navigationController?.popViewController(animated: true)
            
        default:
            break
        }
    }
    
    // MARK: - state method
    /// Get notice attributed text from string
    private func getNoticeAttributedText(_ text: String) -> NSAttributedString {
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12.adjust()
        
        // Set attributed string
        return NSAttributedString(string: text, attributes: [
            .font: Constants.Font.Regular.withSize(15.adjust()),
            .foregroundColor: Constants.Color.codGray,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    deinit {
        Logger.verbose()
    }
}

extension NoticeDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetThreshold: CGFloat = 3
        let blurThreshold: CGFloat = 10
        let weight: CGFloat = 5
        
        // Set shadow by scroll
        headerView.layer.shadow(alpha: 0.04,
                                offset: CGSize(width: 0, height: min(scrollView.contentOffset.y / weight, offsetThreshold)),
                                blur: min(scrollView.contentOffset.y / weight, blurThreshold))
    }
}
