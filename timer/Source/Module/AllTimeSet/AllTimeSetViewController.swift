//
//  AllTimeSetViewController.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class AllTimeSetViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var allTimeSetView: AllTimeSetView { view as! AllTimeSetView }
    
    override var headerView: CommonHeader { allTimeSetView.headerView }
    
    private var timeSetCollectionView: UICollectionView { allTimeSetView.timeSetCollectionView }
    private var loadingView: CommonLoading { allTimeSetView.loadingView }
    
    // MARK: - properties
    var coordinator: AllTimeSetViewCoordinator
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<AllTimeSetSectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, reactor -> UICollectionViewCell in
        guard let type = self?.reactor?.currentState.type else { fatalError("time set type not declared.") }

        switch type {
        case .saved:
            if indexPath.row > 2 {
                // Small time set cell
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name, for: indexPath) as? SavedTimeSetSmallCollectionViewCell else { fatalError("can't dequeue reusable cell type of `SavedTimeSetSmallCollectionViewCell`.") }
                cell.reactor = reactor
                return cell
            } else {
                // Big time set cell
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetBigCollectionViewCell.name, for: indexPath) as? SavedTimeSetBigCollectionViewCell else { fatalError("can't dequeue reusable cell type of `SavedTimeSetBigCollectionViewCell`.")}
                cell.reactor = reactor
                cell.type = indexPath.item == 0 ? .highlight : .normal
                
                return cell
            }
            
        case .preset:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetCollectionViewCell.name, for: indexPath) as? PresetCollectionViewCell else { fatalError("can't dequeue reusable cell type of `PresetCollectionViewCell`.") }
            cell.reactor = reactor
            return cell
        }
        
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        guard let type = self?.reactor?.currentState.type else { fatalError("time set type not declared.") }
        
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name, for: indexPath) as? TimeSetHeaderCollectionReusableView else { fatalError("can't dequeue reusable supplementary view type of `TimeSetHeaderCollectionReusableView`.") }
            
            switch type {
            case .saved:
                supplementaryView.title = "local_header_title".localized
                
            case .preset:
                supplementaryView.title = "preset_header_title".localized
            }
            
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionHeaderCollectionReusableView.name, for: indexPath) as? TimeSetSectionHeaderCollectionReusableView else { fatalError("can't dequeue reusable supplementary view type of `TimeSetSectionCollectionReusableView`.") }
            
            switch type {
            case .saved:
                supplementaryView.title = "local_saved_time_set_section_title".localized
                
            case .preset:
                supplementaryView.title = "preset_all_section_title".localized
            }
            
            return supplementaryView
            
        default:
            fatalError("unregistered supplementary kind requested.")
        }
    })
    
    // MARK: - constructor
    init(coordinator: AllTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = AllTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set layout delegate
        if let layout = timeSetCollectionView.collectionViewLayout as? JSCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    override func bind() {
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    // MARK: - bine
    func bind(reactor: AllTimeSetViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .take(1)
            .map { .load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.itemSelected
            .withLatestFrom(Observable.combineLatest(
                reactor.state.map { $0.sections.value },
                reactor.state.map { $0.type })
            ) { ($0, $1.0, $1.1) }
            .map { ($1[$0.section].items[$0.item].timeSetItem, $2 == .preset) }
            .subscribe(onNext: { [weak self] in self?.coordinator.present(for: .timeSetDetail($0, canSave: $1), animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.type }
            .distinctUntilChanged()
            .compactMap { [weak self] in self?.getTitleFromType($0) }
            .bind(to: headerView.rx.title)
            .disposed(by: disposeBag)
        
        // Section
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
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
    /// Handle header button tap action according to button type
    func handleHeaderAction(_ action: Header.Action) {
        switch action {
        case .back:
            coordinator.present(for: .dismiss, animated: true)
            
        default:
            break
        }
    }
    
    func getTitleFromType(_ type: AllTimeSetViewReactor.TimeSetType) -> String {
        switch type {
        case .saved:
            return "all_saved_time_set_title".localized
            
        case .preset:
            return "all_preset_title".localized
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension AllTimeSetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = reactor?.currentState.type, let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        let width = collectionView.bounds.width - horizontalInset
        
        switch type {
        case .saved:
            return CGSize(width: width, height: indexPath.row > 2 ? 90.adjust() : 140.adjust())
            
        case .preset:
            return CGSize(width: (width - layout.minimumInteritemSpacing) / 2, height: 140.adjust())
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
