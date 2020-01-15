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

class TimeSetManageViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var timeSetManageView: TimeSetManageView { return view as! TimeSetManageView }
    
    override var headerView: ConfirmHeader { return timeSetManageView.headerView }
    
    var timeSetCollectionView: JSReorderableCollectionView { return timeSetManageView.timeSetCollectionView }
    
    // MARK: - properties
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<TimeSetManageSectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, reactor -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSetManageCollectionViewCell.name, for: indexPath) as? TimeSetManageCollectionViewCell else { fatalError("Can't dequeue reusable cell type of `TimeSetManageCollectionViewCell`.") }
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
                fatalError("Can't dequeue reusable supplementary view type of `TimeSetManageHeaderCollectionReusableView`.")
            }
            return supplementaryView
            
        case JSCollectionViewLayout.Element.sectionHeader.kind:
            // Section header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetManageSectionCollectionReusableView.name, for: indexPath) as? TimeSetManageSectionCollectionReusableView else {
                fatalError("Can't dequeue reusable supplementary view type of `TimeSetManageSectionCollectionReusableView`.")
            }
            
            return supplementaryView
            
        default:
            fatalError("Unregistered supplementary kind requested.")
        }
    }, moveItem: { [weak self] dataSource, sourceIndexPath, destinationIndexPath in
        guard let `self` = self else { return }
        
        Observable.just((sourceIndexPath, destinationIndexPath))
            .do(onNext: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .map { .moveTimeSet(at: $0, to: $1) }
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
        super.bind()
        
        headerView.rx.tap
            .subscribe(onNext: { [weak self] in self?.handleHeaderAction($0) })
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bind(reactor: TimeSetManageViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .take(1)
            .map { .load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        // Sections
        reactor.state
            .map { $0.sections }
            .distinctUntilChanged()
            .map { $0.value }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Applied changes
        reactor.state
            .map { $0.applied }
            .distinctUntilChanged()
            .map { $0.value }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in self?.coordinator.present(for: .dismiss, animated: true) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    func handleHeaderAction(_ action: ConfirmHeader.Action) {
        switch action {
        case .cancel:
            coordinator.present(for: .dismiss, animated: true)
            
        case .confirm:
            reactor?.action.onNext(.apply)
            
        default:
            break
        }
    }
    
    // MARK: - selector
    @objc private func panHandler(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
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
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 12.adjust())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout, visibleHeaderInSection section: Int) -> Bool {
        guard section > 0 else { return false }
        return collectionView.numberOfItems(inSection: section) > 0
    }
}

extension Reactive where Base: TimeSetManageViewController {
    var applied: ControlEvent<Void> {
        guard let reactor = base.reactor else { return ControlEvent(events: Observable.empty()) }
        let source =  reactor.state
            .map { $0.applied }
            .distinctUntilChanged()
            .filter { $0.value }
            .map { _ in }
        
        return ControlEvent(events: source)
    }
}
