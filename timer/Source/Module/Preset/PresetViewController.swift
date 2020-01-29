//
//  PresetViewController.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class PresetViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var presetView: PresetView { view as! PresetView }
    
    override var headerView: CommonHeader { presetView.headerView }
    
    private var timeSetCollectionView: UICollectionView { presetView.timeSetCollectionView }
    
    private var loadingView: CommonLoading { presetView.loadingView }
    
    // MARK: - properties
    var coordinator: PresetViewCoordinator
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<PresetSectionModel>(configureCell: { dataSource, collectionView, indexPath, cellType -> UICollectionViewCell in
        let sectionType = dataSource.sectionModels[indexPath.section].model
        
        switch cellType {
        case let .regular(reactor):
            switch sectionType {
            case .hot:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetBigCollectionViewCell.name, for: indexPath) as? SavedTimeSetBigCollectionViewCell else { fatalError("can't dequeue reusable cell type of `SavedTimeSetBigCollectionViewCell`.") }
                cell.reactor = reactor
                cell.type = indexPath.item == 0 ? .highlight : .normal
                return cell
                
            case .all:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetCollectionViewCell.name, for: indexPath) as? PresetCollectionViewCell else { fatalError("can't dequeue reusable cell type of `PresetCollectionViewCell`.") }
                cell.reactor = reactor
                return cell
            }
            
        case .all:
            switch sectionType {
            case .all:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetAllCollectionViewCell.name, for: indexPath) as? TimeSetAllCollectionViewCell else { fatalError("can't dequeue reusable cell type of `TimeSetAllCollectionViewCell`.") }
                cell.title = "preset_all_show_title".localized
                return cell
                
            default:
                fatalError("doesn't have cell type of all in section \(indexPath.section)")
            }
        }
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name, for: indexPath) as? TimeSetHeaderCollectionReusableView else { fatalError("can't dequeue reusable supplementray view type of `TimeSetHeaderCollectionReusableView`.") }
            supplementaryView.titleLabel.text = "preset_header_title".localized
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionHeaderCollectionReusableView.name, for: indexPath) as? TimeSetSectionHeaderCollectionReusableView else { fatalError("can't dequeue reusable supplementray view type of `TimeSetSectionHeaderCollectionReusableView`.") }
            
            let sectionType = dataSource.sectionModels[indexPath.section].model
            switch sectionType {
            case .hot:
                supplementaryView.title = "preset_hot_section_title".localized
                
            case .all:
                supplementaryView.title = "preset_all_section_title".localized
            }
            
            return supplementaryView
            
        default:
            fatalError("unregistered supplementary kind requested.")
        }
    })
    
    // MARK: - constructor
    init(coordinator: PresetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = PresetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set layout delegate
        if let layout = timeSetCollectionView.collectionViewLayout as? JSCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    // MARK: - bine
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: PresetViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { .refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.itemSelected
            .compactMap { [weak self] in self?.dataSource.sectionModels[$0.section].items[$0.item] }
            .subscribe(onNext: { [weak self] in self?.timeSetSelected(cell: $0) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Preset section
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .compactMap { $0.value }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Loading
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isLoading)
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
    private func timeSetSelected(cell type: PresetCellType) {
        switch type {
        case let .regular(reactor):
            coordinator.present(for: .timeSetDetail(reactor.timeSetItem), animated: true)
            
        case .all:
            break
//            coordinator.present(for: .allTimeSet, animated: true)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension PresetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        let width = collectionView.bounds.width - horizontalInset
        
        let section = dataSource.sectionModels[indexPath.section]
        let sectionType = section.model
        let cellType = section.items[indexPath.item]
        
        switch cellType {
        case .regular:
            switch sectionType {
            case .hot:
                return CGSize(width: width, height: 140.adjust())
                
            case .all:
                return CGSize(width: (width - layout.minimumInteritemSpacing) / 2, height: 140.adjust())
            }
            
        case .all:
            return CGSize(width: width, height: 40.adjust())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 63.adjust())
    }
    
    func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 57.adjust())
    }
}
