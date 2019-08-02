//
//  TimerBadgeCollectionView.swift
//  timer
//
//  Created by JSilver on 2019/07/06.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit
import JSReorderableCollectionView

typealias TimerBadgeSectionModel = SectionModel<Void, TimerBadgeCellType>

class TimerBadgeCollectionView: JSReorderableCollectionView, View {
    // MARK: - constants
    static let centerAnchor = CGPoint(x: -1, y: -1)
    
    // MARK: - properties
    private lazy var _dataSource = RxCollectionViewSectionedReloadDataSource<TimerBadgeSectionModel>(configureCell: { (dataSource, collectionView, indexPath, cellType) -> UICollectionViewCell in
        switch cellType {
        case let .regular(reactor):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeCollectionViewCell.ReuseableIdentifier, for: indexPath) as! TimerBadgeCollectionViewCell
            // Send action into reactor for initialize state
            reactor.action.onNext(.updateOptionVisible(self.isOptionButtonVisible))
            cell.reactor = reactor
            
            return cell
        case .add:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeAddCollectionViewCell.ReuseableIdentifier, for: indexPath)
            // Invalidated layout
            cell.layoutIfNeeded()
            return cell
        }
    })
    
    // Timer badge option button visible/hidden
    var isOptionButtonVisible = true
    
    // Timer badge extra cell config
    fileprivate var extraCell: TimerBadgeCellType?
    fileprivate var shouldShowExtraCell: ([TimerInfo], TimerBadgeCellType) -> Bool = { _, _ in
        return true
    }

    // Timer badge anchor point
    var anchorPoint = CGPoint(x: 0, y: 0)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 60.adjust())
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.reactor = TimerBadgeViewReactor()
    }
    
    convenience init(frame: CGRect) {
        // Create collection view flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        // layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // self-sizing cell
        layout.itemSize = CGSize(width: 75.adjust(), height: 60.adjust())
        layout.minimumInteritemSpacing = 10.adjust()

        self.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Constants.Color.clear
        showsHorizontalScrollIndicator = false
        
        // Register timer badge collection view reusable cell
        register(TimerBadgeCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeCollectionViewCell.ReuseableIdentifier)
        register(TimerBadgeAddCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeAddCollectionViewCell.ReuseableIdentifier)
        
        // Bind common view events
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind() {
        rx.setDelegate(self).disposed(by: disposeBag)
        
        _ = rx.methodInvoked(#selector(layoutSubviews))
            .filter { [weak self] _ in self?.bounds.width ?? 0 > 0 }
            .first()
            .subscribe { [weak self] _ in self?.scrollToBadge(at: IndexPath(row: 0, section: 0), animated: false) }
    }
    
    func bind(reactor: TimerBadgeViewReactor) {
        // MARK: action
        rx.badgeMoved
            .map { Reactor.Action.moveBadge(at: $0.0, to: $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: rx.items(dataSource: _dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - private method
    private func canScrollBadge(at indexPath: IndexPath) -> Bool {
        guard let items = reactor?.currentState.sections[0].items, indexPath.row < items.count else { return false }
        
        let cellType = items[indexPath.row]
        switch cellType {
        case .add:
            return false
        default:
            return true
        }
    }
    
    // MARK: - public method
    /// Set timer badge extra cell config
    func setExtraCell(_ extraCell: TimerBadgeCellType?, shouldShowExtraCell: (([TimerInfo], TimerBadgeCellType) -> Bool)?) {
        self.extraCell = extraCell
        if let shouldShowExtraCell = shouldShowExtraCell {
            self.shouldShowExtraCell = shouldShowExtraCell
        }
    }
    
    /// Animate that move cell to anchor point
    func scrollToBadge(at indexPath: IndexPath, animated: Bool) {
        Logger.debug("[JS] scroll to \(indexPath.row) " + (animated ? "with animation" : ""))
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout,
            let items = reactor?.currentState.sections[0].items,
            indexPath.row < items.count else { return }
        
        let index = CGFloat(indexPath.row)
        // Current cell offset in collection view
        let cellOffset = index * layout.itemSize.width + index * layout.minimumInteritemSpacing
        // Get current cell size
        let cellSize = collectionView(self, layout: layout, sizeForItemAt: indexPath)
        
        var diff = anchorPoint.x // Deference about between cell offset and anchor point
        if anchorPoint == TimerBadgeCollectionView.centerAnchor {
            diff = bounds.width / 2 - cellSize.width / 2
        }
        
        // Animate scroll to anchor point
        setContentOffset(CGPoint(x: cellOffset - diff, y: 0), animated: animated)
    }
}

extension TimerBadgeCollectionView: UICollectionViewDelegate {
    /// Set content inset of collection view to align center
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Ignore if display cell isn't first or last
        guard indexPath.row == 0 || indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 else { return }
        let isFirst = indexPath.row == 0
        
        // Get content inset
        let inset = calcInsetOfCollectionView(collectionView, cell: cell, anchorPoint: anchorPoint, isFirst: isFirst)
        
        // Set content inset to align center cell based on anchor point
        var contentInset = collectionView.contentInset
        if isFirst {
            contentInset.left = inset
        } else {
            contentInset.right = inset
        }
        collectionView.contentInset = contentInset
    }
    
    private func calcInsetOfCollectionView(_ collectionView: UICollectionView, cell: UICollectionViewCell, anchorPoint: CGPoint, isFirst: Bool) -> CGFloat {
        if anchorPoint == TimerBadgeCollectionView.centerAnchor {
            return collectionView.bounds.width / 2 - cell.bounds.width / 2
        } else {
            return isFirst ? anchorPoint.x : collectionView.bounds.width - (cell.bounds.width + anchorPoint.x)
        }
    }
}

extension TimerBadgeCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        guard let reactor = reactor else { return .zero }

        let cellType = reactor.currentState.sections[0].items[indexPath.row]
        switch cellType {
        case .add:
            var size = layout.itemSize
            size.width = 24.adjust()
            return size
        default:
            return layout.itemSize
        }
    }
}

// MARK: - Rx extension
extension Reactive where Base: TimerBadgeCollectionView {
    // MARK: - binder
    var items: Binder<[TimerInfo]> {
        return Binder(base.self) { _, timers in
            Observable.just(timers)
                .map {
                    if let extraCell = self.base.extraCell, self.base.shouldShowExtraCell(timers, extraCell) {
                        // Set timer section model with extra badge if extra badge is exsit & satisfy extra badge show condition
                        return Base.Reactor.Action.updateTimers($0, extraCell)
                    }
                    return Base.Reactor.Action.updateTimers($0, nil)
                }
                .bind(to: self.base.reactor!.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    var selected: Binder<IndexPath> {
        return Binder(base.self) { _, indexPath in
            Observable.just(indexPath)
                .map { Base.Reactor.Action.selectBadge($0) }
                .bind(to: self.base.reactor!.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    // MARK: - control event
    var badgeSelected: ControlEvent<(IndexPath, TimerBadgeCellType)> {
        let source = base.rx.itemSelected
            .flatMap { indexPath -> Observable<(IndexPath, TimerBadgeCellType)> in
                let cellType = self.base.reactor!.currentState.sections[0].items[indexPath.row]
                return .just((indexPath, cellType))
        }
        
        return ControlEvent(events: source)
    }
    
    var badgeMoved: ControlEvent<(IndexPath, IndexPath)> {
        let source = dataSource.methodInvoked(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)))
            .flatMap { a -> Observable<(IndexPath, IndexPath)> in
                guard let sourceIndexPath = a[1] as? IndexPath, let destinationIndexPath = a[2] as? IndexPath else {
                    return .empty()
                }
                
                return .just((sourceIndexPath, destinationIndexPath))
            }
        
        return ControlEvent(events: source)
    }
}

// Timer badge cell type
enum TimerBadgeCellType {
    case regular(TimerBadgeCellReactor)
    case add
    // Define here, if need to add any extra cell type
    
    // Get cell item
    var item: TimerBadgeCellReactor? {
        switch self {
        case let .regular(reactor):
            return reactor
        default:
            return nil
        }
    }
}
