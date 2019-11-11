//
//  OpenSourceLicenseViewController.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class OpenSourceLicenseViewController: BaseHeaderViewController, View {
    // MARK: - view properties
    private var openSourceLicenseView: OpenSourceLicenseView { return view as! OpenSourceLicenseView }
    
    override var headerView: CommonHeader { return openSourceLicenseView.headerView }
    
    private var openSourceTextView: UITextView { return openSourceLicenseView.openSourceTextView }
    
    // MARK: - properties
    var coordinator: OpenSourceLicenseViewCoordinator
    
    // MARK: - constructor
    init(coordinator: OpenSourceLicenseViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = OpenSourceLicenseView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        openSourceTextView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: OpenSourceLicenseViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Scroll to top
        openSourceTextView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] _ in self?.openSourceTextView.setContentOffset(.zero, animated: false) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.license }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .map { $0! }
            .map { $0.data(using: .utf8) }
            .map { [weak self] in self?.getLicenseAttributedText(data: $0!) }
            .bind(to: openSourceTextView.rx.attributedText)
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    // MARK: - state method
    /// Get license attributed text from data
    private func getLicenseAttributedText(data: Data) -> NSAttributedString? {
        return try? NSAttributedString(data: data,
                                       options: [.documentType: NSAttributedString.DocumentType.html],
                                       documentAttributes: nil)
    }
    
    deinit {
        Logger.verbose()
    }
}
