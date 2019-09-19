//
//  NoticeListViewController.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class NoticeListViewController: BaseViewController, View {
    // MARK: - view properties
    private var noticeListView: NoticeListView { return view as! NoticeListView }
    
    private var headerView: CommonHeader { return noticeListView.headerView }
    
    private var noticeTableView: UITableView { return noticeListView.noticeTableView }
    private var emptyView: UIView { return noticeListView.emptyView }
    
    // MARK: - properties
    var coordinator: NoticeListViewCoordinator
    
    let dataSource = RxTableViewSectionedReloadDataSource<NoticeListSectionModel>(configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListTableViewCell.name, for: indexPath) as? NoticeListTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = item.title
        cell.dateLabel.text = getDateString(format: "yy.MM.dd", date: item.date)
        
        return cell
    })
    
    // MARK: - constructor
    init(coordinator: NoticeListViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = NoticeListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell
        noticeTableView.register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.name)
    }
    
    // MARK: - bine
    override func bind() {
        noticeTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: NoticeListViewReactor) {
        // MARK: action
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.headerActionHandler(type: $0) })
            .disposed(by: disposeBag)
        
        noticeTableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.noticeTableView.deselectRow(at: $0, animated: true) })
            .withLatestFrom(reactor.state.map { $0.sections }, resultSelector: { $1[$0.section].items[$0.row] })
            .subscribe(onNext: { Logger.debug($0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .do(onNext: { [weak self] in self?.showNoticeEmptyView(isEmpty: $0.isEmpty || $0[0].items.isEmpty) })
            .bind(to: noticeTableView.rx.items(dataSource: dataSource))
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
    /// Show notice empty view in table view if notice is empty
    private func showNoticeEmptyView(isEmpty: Bool) {
        noticeTableView.isScrollEnabled = !isEmpty
        
        if isEmpty {
            noticeTableView.tableHeaderView = emptyView
            emptyView.frame.size.height = 87.adjust()
        } else {
            noticeTableView.tableHeaderView = nil
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension NoticeListViewController: UIScrollViewDelegate {
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

extension NoticeListViewController: UITableViewDelegate {

}

// MARK: - countdown setting datasource
typealias NoticeListSectionModel = SectionModel<Void, Notice>
