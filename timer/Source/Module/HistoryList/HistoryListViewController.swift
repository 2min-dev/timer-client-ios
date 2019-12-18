//
//  HistoryListViewController.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class HistoryListViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var historyListView: HistoryListView { return view as! HistoryListView }
    
    override var headerView: CommonHeader { return historyListView.headerView }
    
    private var historyCollectionView: UICollectionView { return historyListView.historyCollectionView }
    
    // MARK: - properties
    var coordinator: HistoryListViewCoordinator
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HistorySectionModel>(configureCell: { datasource, collectionView, indexPath, reactor in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryListCollectionViewCell.name, for: indexPath) as? HistoryListCollectionViewCell else { fatalError() }
        
        cell.reactor = reactor
        return cell
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
        guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HistoryListEmptyCollectionReusableView.name, for: indexPath) as? HistoryListEmptyCollectionReusableView else { fatalError("Collection view doesn't have supplementary view type of HistoryListEmptyCollectionReusableView") }
        
        if let self = self {
            // Bind create button action
            supplementaryView.createButton.rx.tap
                .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .productivity, animated: true) })
                .disposed(by: self.disposeBag)
        }
        
        return supplementaryView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register reusable view
        historyCollectionView.register(HistoryListEmptyCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HistoryListEmptyCollectionReusableView.name)
        
        // Register cell
        historyCollectionView.register(HistoryListCollectionViewCell.self, forCellWithReuseIdentifier: HistoryListCollectionViewCell.name)
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
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
            .withLatestFrom(reactor.state.map { $0.sections },
                            resultSelector: { $1.first?.items[$0.item] })
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in _ = self?.coordinator.present(for: .detail($0.history), animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: historyCollectionView.rx.items(dataSource: dataSource))
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard reactor?.currentState.sections.first?.items.count ?? 0 == 0,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        // Calculate inset size of header view
        var inset = headerView.bounds.height + layout.sectionInset.bottom
        if #available(iOS 11.0, *) {
            inset -= view.safeAreaInsets.top // Status bar inset
        } else {
            inset -= 20 // Status bar inset hard cording if os version lower than 11.0
        }
        
        return CGSize(width: 0, height: collectionView.bounds.height - inset)
    }
}

// MARK: - setting datasource
typealias HistorySectionModel = SectionModel<Void, HistoryListCollectionViewCellReactor>
