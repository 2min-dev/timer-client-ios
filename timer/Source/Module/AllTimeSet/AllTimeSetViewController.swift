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

        if indexPath.row > 2 {
            // Small time set cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name, for: indexPath) as? SavedTimeSetSmallCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `SavedTimeSetSmallCollectionViewCell`.") }
            cell.reactor = cellReactor
            return cell
        } else {
            // Big time set cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedTimeSetBigCollectionViewCell.name, for: indexPath) as? SavedTimeSetBigCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `SavedTimeSetBigCollectionViewCell`.")}
            cell.reactor = cellReactor
            cell.type = indexPath.item == 0 ? .highlight : .normal
            
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
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionHeaderCollectionReusableView.name, for: indexPath) as? TimeSetSectionHeaderCollectionReusableView,
                let reactor = self?.reactor else {
                fatalError("Can't dequeue reusable supplementary view type of `TimeSetSectionCollectionReusableView`.")
            }

            // Set header type & title
            supplementaryView.title = "local_saved_time_set_section_title".localized
            
            return supplementaryView
            
        default:
            fatalError("Unregistered supplementary kind requested.")
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
    
    deinit {
        Logger.verbose()
    }
}

extension AllTimeSetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        let width = collectionView.bounds.width - horizontalInset
        
        if indexPath.row > 2 {
            return CGSize(width: width, height: 90.adjust())
        } else {
            return CGSize(width: width, height: 140.adjust())
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
}
