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
import JSReorderableCollectionView

class TimeSetManageViewController: BaseViewController, View {
    // MARK: - view properties
    private var timeSetManageView: TimeSetManageView { return view as! TimeSetManageView }
    
    var headerView: ConfirmHeader { return timeSetManageView.headerView }
    
    var timeSetCollectionView: JSReorderableCollectionView { return timeSetManageView.timeSetCollectionView }
    
    // MARK: - properties
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<TimeSetManageSectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, reactor -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetManageCollectionViewCell.name, for: indexPath) as? TimeSetManageCollectionViewCell else { return UICollectionViewCell() }
            // Inject cell reactor
            cell.reactor = reactor
            
            // Bind cell action
            cell.editButton.rx.tap
                .map { self?.timeSetCollectionView.indexPath(for: cell) }
                .filter { $0 != nil }
                .map { $0! }
                .map { Reactor.Action.editTimeSet(at: $0) }
                .subscribe(onNext: { self?.reactor?.action.onNext($0) })
                .disposed(by: cell.disposeBag)
            
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
    }, moveItem: { [weak self] dataSource, sourceIndexPath, destinationIndexPath in
        guard let `self` = self else { return }
        
        Observable.just((sourceIndexPath, destinationIndexPath))
            .map { Reactor.Action.moveTimeSet(at: $0, to: $1) }
            .subscribe(onNext: { self.reactor?.action.onNext($0) })
            .disposed(by: self.disposeBag)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register supplimentary view
        timeSetCollectionView.register(TimeSetManageHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetManageHeaderCollectionReusableView.name)
        timeSetCollectionView.register(TimeSetManageSectionCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.sectionHeader.kind, withReuseIdentifier: TimeSetManageSectionCollectionReusableView.name)
        
        // Register cell
        timeSetCollectionView.register(TimeSetManageCollectionViewCell.self, forCellWithReuseIdentifier: TimeSetManageCollectionViewCell.name)
        
        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(gesture:)))
        panGesture.delegate = self
        timeSetCollectionView.addGestureRecognizer(panGesture)
        
        // Set reorderable delegate
        timeSetCollectionView.reorderableDelegate = self
        
        // Set layout delegate
        if let layout = timeSetCollectionView.collectionViewLayout as? JSCollectionViewLayout {
            layout.delegate = self
        }
    }
    
    // MARK: - bine
    override func bind() {
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetManageViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        headerView.rx.cancel
            .subscribe(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
        
        headerView.rx.confirm
            .map { Reactor.Action.apply }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
        
        reactor.state
            .map { $0.shouldDismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
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
    
    // MARK: - selector
    @objc private func panHandler(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: timeSetCollectionView.superview)
            timeSetCollectionView.beginInteractiveWithLocation(location)
            
        case .changed:
            let location = gesture.location(in: timeSetCollectionView.superview)
            timeSetCollectionView.updateInteractiveWithLocation(location)
            
        default:
            timeSetCollectionView.finishInteractive()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

extension TimeSetManageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: timeSetCollectionView)
        guard let indexPath = timeSetCollectionView.indexPathForItem(at: point),
            let cell = timeSetCollectionView.cellForItem(at: indexPath) as? TimeSetManageCollectionViewCell else { return false }
        
        return cell.reorderButton.frame.contains(timeSetCollectionView.convert(point, to: cell))
    }
}

extension TimeSetManageViewController: JSReorderableCollectionViewDelegate {
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willAppear snapshot: UIView, source cell: UICollectionViewCell, at point: CGPoint) {
        guard let superview = collectionView.superview else { return }
        
        // Initialize cell & snapshot view
        snapshot.center = collectionView.convert(cell.center, to: superview)
        cell.isHidden = true
        
        UIView.animate(withDuration: 0.2, animations: {
            snapshot.center = point
            snapshot.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout, visibleHeaderInSection section: Int) -> Bool {
        guard section > 0 else { return false }
        return collectionView.numberOfItems(inSection: section) > 0
    }
}

// MARK: - time set manage datasource
typealias TimeSetManageSectionModel = AnimatableSectionModel<TimeSetManageSectionType, TimeSetManageCollectionViewCellReactor>

enum TimeSetManageSectionType: Int, IdentifiableType {
    case normal
    case removed
    
    var identity: Int {
        return rawValue
    }
}
