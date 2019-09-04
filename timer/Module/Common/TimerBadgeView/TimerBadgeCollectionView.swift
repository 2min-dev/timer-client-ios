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
    // MARK: - properties
    private lazy var _dataSource = RxCollectionViewSectionedReloadDataSource<TimerBadgeSectionModel>(configureCell: { (dataSource, collectionView, indexPath, cellType) -> UICollectionViewCell in
        switch cellType {
        case let .regular(reactor):
            // Send action into reactor for initialize state
            reactor.action.onNext(.enable(self.isEnabled))
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeCollectionViewCell.name, for: indexPath) as! TimerBadgeCollectionViewCell
            cell.reactor = reactor
            
            return cell
        case .add:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeAddCollectionViewCell.name, for: indexPath)
            // Invalidated layout
            cell.layoutIfNeeded()
            return cell
        }
    })
    
    var isEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            reactor?.action.onNext(.refresh)
        }
    }
    
    // Timer badge extra cell config
    fileprivate var extraCell: TimerBadgeCellType?
    fileprivate var shouldShowExtraCell: ([TimerInfo], TimerBadgeCellType) -> Bool = { _, _ in
        return true
    }

    // Timer badge flow layout
    var layout: TimerBadgeCollectionViewFlowLayout?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 60.adjust())
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.layout = layout as? TimerBadgeCollectionViewFlowLayout
        super.init(frame: frame, collectionViewLayout: layout)
        self.reactor = TimerBadgeViewReactor()
        
        // Set collection view properties
        backgroundColor = Constants.Color.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        // Set layout properties
        self.layout?.scrollDirection = .horizontal
        self.layout?.minimumInteritemSpacing = 30.adjust()
        self.layout?.delegate = self
        
        // Register timer badge collection view reusable cell
        register(TimerBadgeCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeCollectionViewCell.name)
        register(TimerBadgeAddCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeAddCollectionViewCell.name)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: TimerBadgeCollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    /// Animate that move cell to axis point
    func scrollToBadge(at indexPath: IndexPath, animated: Bool) {
        guard let layout = collectionViewLayout as? TimerBadgeCollectionViewFlowLayout,
            let items = reactor?.currentState.sections[0].items,
            indexPath.row < items.count else { return }

        let index = CGFloat(indexPath.row)
        // Get current cell size
        let cellSize = collectionView(self, layout: layout, sizeForItemAt: indexPath)
        // Current cell offset in collection view
        let cellOffset = index * cellSize.width + index * layout.minimumInteritemSpacing + layout.sectionInset.left
        
        // Deference about between cell offset and axis point
        var diff: CGFloat
        switch layout.axisAlign {
        case .left:
            diff = layout.axisPoint.x
        case .center:
            diff = layout.axisPoint.x - cellSize.width / 2
        case .right:
            diff = layout.axisPoint.x - cellSize.width
        }

        // Animate scroll to axis point
        setContentOffset(CGPoint(x: cellOffset - diff, y: 0), animated: animated)
    }
}

extension TimerBadgeCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let reactor = reactor else { return .zero }

        let cellType = reactor.currentState.sections[0].items[indexPath.row]
        switch cellType {
        case .add:
            return CGSize(width: 50.adjust(), height: 30.adjust())
        default:
            return CGSize(width: 108.adjust(), height: 60.adjust())
        }
    }
}

// MARK: - Rx extension
extension Reactive where Base: TimerBadgeCollectionView {
    // MARK: - binder
    var items: Binder<[TimerInfo]> {
        return Binder(base.self) { _, timers in
            guard let reactor = self.base.reactor else { return }
            
            Observable.just(timers)
                .map {
                    if let extraCell = self.base.extraCell, self.base.shouldShowExtraCell(timers, extraCell) {
                        // Set timer section model with extra badge if extra badge is exsit & satisfy extra badge show condition
                        return Base.Reactor.Action.updateTimers($0, extraCell)
                    }
                    return Base.Reactor.Action.updateTimers($0, nil)
                }
                .bind(to: reactor.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    var selected: Binder<IndexPath> {
        return Binder(base.self) { _, indexPath in
        guard let reactor = self.base.reactor else { return }
            
            Observable.just(indexPath)
                .map { Base.Reactor.Action.selectBadge(at: $0) }
                .bind(to: reactor.action)
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

class TimerBadgeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // MARK: - constants
    enum Axis {
        static let center = CGPoint(x: -1, y: -1)
    }
    
    enum Align {
        case left
        case center
        case right
    }
    
    // MARK: - properties
    weak var delegate: UICollectionViewDelegateFlowLayout?
    
    private var attributesCache: [UICollectionViewLayoutAttributes] = []
    private var _axisPoint: CGPoint = .zero
    var axisPoint: CGPoint {
        set { _axisPoint = newValue }
        get { return _axisPoint == Axis.center ? CGPoint(x: (collectionView?.bounds.width ?? 0) / 2, y: _axisPoint.y) : _axisPoint }
    }
    var axisAlign: Align = .center
    
    private var contentSize: CGSize = .zero
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }

        let count = collectionView.numberOfItems(inSection: 0)
        // Init section inset
        sectionInset = calcSectionInset(in: collectionView, section: 0)
        // Add horizontal section left inset to content size
        contentSize = CGSize(width: sectionInset.left, height: collectionView.bounds.height)
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        (0 ..< count).forEach {
            let indexPath = IndexPath(row: $0, section: 0)
            let itemSize = delegate?.collectionView?(collectionView,
                                                    layout: self,
                                                    sizeForItemAt: indexPath) ?? self.itemSize

            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = CGRect(x: contentSize.width,
                                     y: (contentSize.height - itemSize.height) / 2,
                                     width: itemSize.width,
                                     height: itemSize.height)

            attributes.append(attribute)
            // Add item size to content width
            contentSize.width += itemSize.width + ($0 < count - 1 ? minimumInteritemSpacing : 0)
        }
        // Add horizontal section right inset to content size
        contentSize.width += sectionInset.right

        attributesCache = attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesCache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache[indexPath.item]
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Get layout attributes in target rect
        let targetRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let layoutAttributes = layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        // Calculate base axis point.
        let axisX = proposedContentOffset.x + axisPoint.x
        
        // Calculate content offset adjustment between center of content offset and most closest item
        layoutAttributes.forEach {
            var diff: CGFloat
            switch axisAlign {
            case .left:
                diff = $0.frame.origin.x - axisX
            case .center:
                diff = $0.center.x - axisX
            case .right:
                diff = $0.frame.origin.x + $0.bounds.width - axisX
            }
            
            if diff.magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = diff
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    // MARK: - private method
    private func calcSectionInset(in collectionView: UICollectionView, section: Int) -> UIEdgeInsets {
        let count = collectionView.numberOfItems(inSection: section)
        guard count > 0 else { return .zero }

        let firstIndexPath = IndexPath(row: 0, section: section)
        let lastIndexPath = IndexPath(row: count - 1, section: section)
        
        // Get first & last item size
        let firstItem = delegate?.collectionView?(collectionView,
                                                 layout: self,
                                                 sizeForItemAt: firstIndexPath) ?? self.itemSize
        let lastItem = delegate?.collectionView?(collectionView,
                                                layout: self,
                                                sizeForItemAt: lastIndexPath) ?? self.itemSize
        
        switch axisAlign {
        case .left:
            return UIEdgeInsets(top: 0,
                                left: axisPoint.x,
                                bottom: 0,
                                right: collectionView.bounds.width - (axisPoint.x + lastItem.width))
        case .center:
            return UIEdgeInsets(top: 0,
                                left: axisPoint.x - firstItem.width / 2,
                                bottom: 0,
                                right: axisPoint.x - lastItem.width / 2)
        case .right:
            return UIEdgeInsets(top: 0,
                                left: axisPoint.x - firstItem.width,
                                bottom: 0,
                                right: collectionView.bounds.width - axisPoint.x)
        }
    }
}
