//
//  TeamInfoViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TeamInfoViewController: BaseHeaderViewController, ViewControllable, View {
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
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        scrollView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
	func bind(reactor: TeamInfoViewReactor) {
		// MARK: action
        copyButton.rx.tap
            .do(onNext: { Toast(content: "toast_team_info_copy_email_title".localized).show(animated: true, withDuration: 3) })
            .subscribe(onNext: { [weak self] in UIPasteboard.general.string = self?.emailLabel.text })
            .disposed(by: disposeBag)

		// MARK: state
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
    
    deinit {
        Logger.verbose()
    }
}
