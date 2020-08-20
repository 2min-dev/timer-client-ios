//
//  HistoryListViewController.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class HistoryListViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var root: HistoryListView { view as! HistoryListView }
    
    override var headerView: CommonHeader { root.headerView }
    
    private var historyListEmptyView: UIView { root.historyListEmptyView }
    private var createButton: UIButton { root.createButton }
    private var historyCollectionView: UICollectionView { root.historyCollectionView }
    
    // MARK: - properties
    var coordinator: HistoryListViewCoordinator
    
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<HistorySectionModel>(configureCell: { [weak self] datasource, collectionView, indexPath, reactor in
        guard let self = self, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryListCollectionViewCell.name, for: indexPath) as? HistoryListCollectionViewCell else { fatalError() }
        
        cell.reactor = reactor
        // Delete the history
        cell.rx.delete
            .map { .deleteHistory(id: reactor.history.id) }
            .subscribe(onNext: { [weak self] in self?.reactor?.action.onNext($0) })
            .disposed(by: self.disposeBag)
        
        return cell
    })
    
    // MARK: - constructor
    init(coordinator: HistoryListViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = HistoryListView()
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.coordinator.present(for: .productivity, animated: true) })
            .disposed(by: disposeBag)
        
        historyCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: HistoryListViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        historyCollectionView.rx.itemSelected
            .withLatestFrom(reactor.state.map { $0.sections.value }) { $1[$0.section].items[$0.item] }
            .subscribe(onNext: { [weak self] in self?.coordinator.present(for: .detail($0.history), animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
        let sections = reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .share()
        
        // Sections
        sections
            .bind(to: historyCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Empty view hidden
        sections.map { !$0.isEmpty && !($0.first?.items.isEmpty ?? false)  }
            .bind(to: historyListEmptyView.rx.isHidden)
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
    
    deinit {
        Logger.verbose()
    }
}

extension HistoryListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 90.adjust())
    }
}
