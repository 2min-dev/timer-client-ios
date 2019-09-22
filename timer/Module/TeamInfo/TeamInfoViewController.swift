//
//  TeamInfoViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TeamInfoViewController: BaseHeaderViewController, View {
	// MARK: - view properties
	private var teamInfoView: TeamInfoView { return view as! TeamInfoView }
    
    override var headerView: CommonHeader { return teamInfoView.headerView }
    
    private var emailLabel: UILabel { return teamInfoView.emailLabel }
    private var copyButton: UIButton { return teamInfoView.copyButton }
    
    private var scrollView: UIScrollView { return teamInfoView.scrollView }
	
	// MARK: - properties
	var coordinator: TeamInfoViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TeamInfoViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	// MARK: - lifecycle
	override func loadView() {
		view = TeamInfoView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - bind
    override func bind() {
        super.bind()
        
        scrollView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
	func bind(reactor: TeamInfoViewReactor) {
		// MARK: action
        copyButton.rx.tap
            .do(onNext: { [weak self] in self?.showEmailCopiedAlert() })
            .subscribe(onNext: { [weak self] in UIPasteboard.general.string = self?.emailLabel.text })
            .disposed(by: disposeBag)

		// MARK: state
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
    
    /// Show email copied alert view
    private func showEmailCopiedAlert() {
        let alert = AlertBuilder(message: "복사되었습니다").build()
        // Alert view controller dismiss after 1 seconds
        alert.rx.viewDidLoad
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak alert] in alert?.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        // Present alert view controller
        present(alert, animated: true)
    }
    
    deinit {
        Logger.verbose()
    }
}
