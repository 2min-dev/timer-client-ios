//
//  TimeSetManageViewController.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class TimeSetManageViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetManageView: TimeSetManageView { return view as! TimeSetManageView }
    
    var headerView: ConfirmHeader { return timeSetManageView.headerView }
    
    var timeSetCollectionView: UICollectionView { return timeSetManageView.timeSetCollectionView }
    
    // MARK: - properties
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<TimeSetManageSectionModel>(configureCell: { dataSource, collectionView, indexPath, cellType -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetManageCollectionViewCell.name, for: indexPath) as? TimeSetManageCollectionViewCell else { return UICollectionViewCell() }
        
        // Inject cell reactor
//        cell.reactor = reactor
        
        if indexPath.section == TimeSetManageSectionType.normal.rawValue {
            cell.editButton.isSelected = false
        } else {
            cell.editButton.isSelected = true
        }
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetManageHeaderCollectionReusableView.name, for: indexPath) as? TimeSetManageHeaderCollectionReusableView else {
                return UICollectionReusableView()
            }
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetManageSectionCollectionReusableView.name, for: indexPath) as? TimeSetManageSectionCollectionReusableView else {
                return UICollectionReusableView()
            }
            
            return supplementaryView
            
        default:
            return UICollectionReusableView()
        }
    })
    
    var coordinator: TimeSetManageViewCoordinator
    
    // MARK: - constructor
    init(coordinator: TimeSetManageViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = TimeSetManageView()
        
        // Register supplimentary view
        timeSetCollectionView.register(TimeSetManageHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetManageHeaderCollectionReusableView.name)
        timeSetCollectionView.register(TimeSetManageSectionCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.sectionHeader.kind, withReuseIdentifier: TimeSetManageSectionCollectionReusableView.name)
        
        // Register cell
        timeSetCollectionView.register(TimeSetManageCollectionViewCell.self, forCellWithReuseIdentifier: TimeSetManageCollectionViewCell.name)
        
        // Set layout delegate
        if let layout = timeSetCollectionView.collectionViewLayout as? JSCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - bine
    override func bind() {
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetManageViewReactor) {
        // MARK: action
        
        // MARK: state
        reactor.state
            .map { $0.type }
            .map { [weak self] in self?.getHeaderTitleByType($0) ?? "" }
            .bind(to: headerView.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    // MARK: - state method
    /// Get header title by type
    private func getHeaderTitleByType(_ type: TimeSetManageViewReactor.TimeSetType) -> String {
        switch type {
        case .saved:
            return "saved_time_set_title".localized
            
        case .bookmarked:
            return "bookmarked_time_set_title".localized
        }
    }
    
    // MARK: - priate method
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}

extension TimeSetManageViewController: UIScrollViewDelegate {
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

extension TimeSetManageViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 60.adjust())
    }
    
    func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 93.adjust())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard section > 0 else { return .zero }
        
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 12.adjust())
    }
}

// MARK: - time set manage datasource
typealias TimeSetManageSectionModel = SectionModel<Void, String>

enum TimeSetManageSectionType: Int {
    case normal
    case removed
}
