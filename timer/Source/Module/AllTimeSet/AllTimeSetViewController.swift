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
    private var allTimeSetView: AllTimeSetView { return view as! AllTimeSetView }
    
    override var headerView: CommonHeader { return allTimeSetView.headerView }
    
    private var timeSetCollectionView: UICollectionView { return allTimeSetView.timeSetCollectionView }
    
    // MARK: - properties
    var coordinator: AllTimeSetViewCoordinator
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<AllTimeSetSectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, cellReactor -> UICollectionViewCell in
        guard let reactor = self?.reactor else { return UICollectionViewCell() }

        let type = reactor.currentState.type
        if type == .saved {
            // Saved time set
            if indexPath.row > 0 {
                // Highlight time set
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetCollectionViewCell.name, for: indexPath) as? SavedTimeSetCollectionViewCell else { return UICollectionViewCell() }
                cell.reactor = cellReactor
                return cell
            } else {
                // Normal time set
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetHighlightCollectionViewCell.name, for: indexPath) as? SavedTimeSetHighlightCollectionViewCell else { return UICollectionViewCell() }
                cell.reactor = cellReactor
                return cell
            }
        } else {
            // Bookmared time set
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmaredTimeSetCollectionViewCell.name, for: indexPath) as? BookmaredTimeSetCollectionViewCell else { return UICollectionViewCell() }
            cell.reactor = cellReactor
            return cell
        }
        
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name, for: indexPath) as? TimeSetHeaderCollectionReusableView else {
                return UICollectionReusableView()
            }
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionCollectionReusableView.name, for: indexPath) as? TimeSetSectionCollectionReusableView,
                let reactor = self?.reactor else {
                return UICollectionReusableView()
            }

            // Set view type
            supplementaryView.type = .title
            
            let type = reactor.currentState.type
            // Set header text
            if type == .saved {
                // Saved time set
                supplementaryView.titleLabel.text = "local_saved_time_set_section_title".localized
            } else {
                // Bookmarked time set
                supplementaryView.titleLabel.text = "local_bookmarked_time_set_section_title".localized
            }
            
            return supplementaryView
            
        default:
            return UICollectionReusableView()
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
            .withLatestFrom(reactor.state.map { $0.sections.value }, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] in self?.coordinator.present(for: .timeSetDetail($1[$0.section].items[$0.item].timeSetItem), animated: true) })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Title
        reactor.state
            .map { $0.type }
            .map { [weak self] in self?.getHeaderTitleByType($0) ?? "" }
            .bind(to: headerView.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
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
    
    // MARK: - state method
    /// Get header title by type
    private func getHeaderTitleByType(_ type: AllTimeSetViewReactor.TimeSetType) -> String {
        switch type {
        case .saved:
            return "saved_time_set_title".localized
            
        case .bookmarked:
            return "bookmarked_time_set_title".localized
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension AllTimeSetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout, let reactor = reactor else { return .zero }
        
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        var size = CGSize(width: collectionView.bounds.width - horizontalInset, height: 0)
        
        if reactor.currentState.type == .saved {
            // Saved time set
            size.height = 140.adjust()
            if indexPath.row > 0 {
                // Set width that half of collection view width except first time set
                size.width = (size.width - layout.minimumInteritemSpacing) / 2
            }
        } else {
            // Bookmarked time set
            size.height = 90.adjust()
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.adjust()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 79.adjust())
    }
    
    func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 87.adjust())
    }
}
