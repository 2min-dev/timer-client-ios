//
//  LocalTimeSetViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class LocalTimeSetViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var localTimeSetView: LocalTimeSetView { return view as! LocalTimeSetView }
    
    override var headerView: CommonHeader { return localTimeSetView.headerView }
    
    private var timeSetCollectionView: UICollectionView { return localTimeSetView.timeSetCollectionView }
    
    // MARK: - properties
    var coordinator: LocalTimeSetViewCoordinator
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<LocalTimeSetSectionModel>(configureCell: { dataSource, collectionView, indexPath, cellType -> UICollectionViewCell in
        let sectionType = dataSource.sectionModels[indexPath.section].model
        
        switch cellType {
        case let .regular(reactor):
            switch sectionType {
            case .saved:
                // Saved time set
                if indexPath.item > 2 {
                    // Highlight time set
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name, for: indexPath) as? SavedTimeSetSmallCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `SavedTimeSetSmallCollectionViewCell`.") }
                    cell.reactor = reactor
                    return cell
                } else {
                    // Normal time set
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetBigCollectionViewCell.name, for: indexPath) as? SavedTimeSetBigCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `SavedTimeSetBigCollectionViewCell`.") }
                    cell.reactor = reactor
                    cell.type = indexPath.item == 0 ? .highlight : .normal
                    
                    return cell
                }
                
            case .recentlyUsed:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name, for: indexPath) as? SavedTimeSetSmallCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `SavedTimeSetSmallCollectionViewCell`.") }
                cell.reactor = reactor
                return cell
            }
            
        case .empty:
            // Induce time set create
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetInduceCollectionViewCell.name, for: indexPath)
            return cell
            
        case .all:
            switch sectionType {
            case .saved:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetAllCollectionViewCell.name, for: indexPath) as? TimeSetAllCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `TimeSetAllCollectionViewCell`.") }
                cell.title = "local_saved_time_set_all_show_title".localized
                return cell
                
            default:
                fatalError("Doesn't have cell type of all in section \(indexPath.section)")
            }
        }
        
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name, for: indexPath) as? TimeSetHeaderCollectionReusableView else {
                fatalError("Can't dequeue reusable supplementary view type of `TimeSetHeaderCollectionReusableView`.")
            }
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionHeaderCollectionReusableView.name, for: indexPath) as? TimeSetSectionHeaderCollectionReusableView  else { fatalError("Can't dequeue reusable supplementary view type of `TimeSetSectionHeaderCollectionReusableView`.") }
            
            let section = dataSource.sectionModels[indexPath.section]
            let sectionType = section.model
            
            // Set header text
            switch sectionType {
            case .saved:
                // Saved time set
                supplementaryView.title = "local_saved_time_set_section_title".localized
                
                if let cellType = section.items.first {
                    // Set additional button, if item exist
                    switch cellType {
                    case .regular:
                        supplementaryView.additionalText = "local_management_title".localized
                        
                    default:
                        break
                    }
                }
                
                // Present to saved time set manage
                supplementaryView.rx.tap
                    .subscribe(onNext: { [weak self] in
                        guard let viewController = self?.coordinator.present(for: .timeSetManage, animated: true) as? TimeSetManageViewController else { return }
                        self?.bind(manage: viewController)
                    })
                    .disposed(by: supplementaryView.disposeBag)
                
            case .recentlyUsed:
                // Recently used time set
                supplementaryView.title = "local_recently_used_time_set_section_title".localized
            }
            
            return supplementaryView
            
        default:
            fatalError("Unregistered supplementary kind requested.")
        }
    })
    
    // MARK: - constructor
    init(coordinator: LocalTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = LocalTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set layout delegate
        if let layout = timeSetCollectionView.collectionViewLayout as? JSCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    // MARK: - bind
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: LocalTimeSetViewReactor) {
        // MARK: action
        Observable.merge(rx.viewDidLoad.asObservable(),
                         rx.viewWillAppear.asObservable())
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.itemSelected
            .withLatestFrom(reactor.state.map { $0.sections.value }, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] in self?.timeSetSelected(cell: $1[$0.section].items[$0.item]) })
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func bind(manage viewControler: TimeSetManageViewController) {
        guard let reactor = reactor else { return }
        
        viewControler.rx.applied
            .map { .refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    func handleHeaderAction(_ action: CommonHeader.Action) {
        switch action {
        case .history:
            coordinator.present(for: .history, animated: true)
            
        case .setting:
            coordinator.present(for: .setting, animated: true)
            
        default:
            break
        }
    }
    
    /// Perform present by selected cell type
    private func timeSetSelected(cell type: LocalTimeSetCellType) {
        switch type {
        case let .regular(reactor):
            coordinator.present(for: .timeSetDetail(reactor.timeSetItem), animated: true)
            
        case .empty:
            coordinator.present(for: .productivity, animated: true)
            
        case .all:
            coordinator.present(for: .allTimeSet, animated: true)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension LocalTimeSetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate cell width
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        let width = collectionView.bounds.width - horizontalInset
        
        // Get item type
        let section = dataSource.sectionModels[indexPath.section]
        
        let sectionType = section.model
        let cellType = section.items[indexPath.item]
        
        switch cellType {
        case .regular:
            switch sectionType {
            case .saved:
                if indexPath.item <= 2 {
                    return CGSize(width: width, height: 140.adjust())
                }
                fallthrough
                
            default:
                return CGSize(width: width, height: 90.adjust())
            }
            
        case .empty:
            return CGSize(width: width, height: 140.adjust())
            
        case .all:
            return CGSize(width: width, height: 40.adjust())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.adjust()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 63.adjust())
    }
    
    func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 57.adjust())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout, visibleHeaderInSection section: Int) -> Bool {
        !(reactor?.currentState.sections.value[section].items.isEmpty ?? false)
    }
}
