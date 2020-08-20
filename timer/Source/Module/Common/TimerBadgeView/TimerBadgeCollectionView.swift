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
import JSReorderableCollectionView

class TimerBadgeCollectionView: JSReorderableCollectionView {
    // MARK: - properties
    var isEditable: Bool = false
    
    lazy var _dataSource = RxCollectionViewSectionedAnimatedDataSource<TimerBadgeSectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, cellType -> UICollectionViewCell in
        switch cellType {
        case let .regular(reactor):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeCollectionViewCell.name, for: indexPath) as? TimerBadgeCollectionViewCell else { fatalError() }
            cell.reactor = reactor
            cell.editButton.isHidden = !(self?.isEditable ?? false)
            
            return cell
            
        case let .extra(type):
            switch type {
            case .add:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeAddCollectionViewCell.name, for: indexPath)
                
                return cell
                
            case let .repeat(reactor):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeRepeatCollectionViewCell.name, for: indexPath) as? TimerBadgeRepeatCollectionViewCell else { fatalError() }
                cell.reactor = reactor
                
                return cell
            }
        }
    })
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 90.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        // Set collection view properties
        backgroundColor = Constants.Color.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        // Register timer badge collection view reusable cell
        register(TimerBadgeCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeCollectionViewCell.name)
        register(TimerBadgeAddCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeAddCollectionViewCell.name)
        register(TimerBadgeRepeatCollectionViewCell.self, forCellWithReuseIdentifier: TimerBadgeRepeatCollectionViewCell.name)
        
        // Set delegate
        delegate = self
        reorderableDelegate = self
        
        if let layout = collectionViewLayout as? TimerBadgeCollectionViewFlowLayout {
            // Set layout properties
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10.adjust()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 25.adjust(), bottom: 0, right: 25.adjust())
        }
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: TimerBadgeCollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    /// Animate that move cell to axis point
    func scrollToBadge(at indexPath: IndexPath, animated: Bool) {
        guard let layout = collectionViewLayout as? TimerBadgeCollectionViewFlowLayout,
            let cellAttribute = layout.layoutAttributesForItem(at: indexPath) else { return }
        
        // Deference about between cell offset and axis point
        var diff: CGFloat
        switch layout.axisAlign {
        case .left:
            diff = layout.axisPoint.x
            
        case .center:
            diff = layout.axisPoint.x - cellAttribute.size.width / 2
            
        case .right:
            diff = layout.axisPoint.x - cellAttribute.size.width
        }
        
        // Animate scroll to axis point
        setContentOffset(CGPoint(x: cellAttribute.frame.origin.x - diff, y: 0), animated: animated)
    }
}

extension TimerBadgeCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 40.adjust(), height: 40.adjust())
        } else if indexPath.section == 1 {
            return CGSize(width: 130.adjust(), height: 70.adjust())
        } else {
            return CGSize(width: 40.adjust(), height: 40.adjust())
        }
    }
}

extension TimerBadgeCollectionView: JSReorderableCollectionViewDelegate {
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == TimerBadgeSectionType.regular.rawValue else { return false }
        return true
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
    private var attributesCache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    weak var delegate: UICollectionViewDelegateFlowLayout?
    
    private var contentSize: CGSize = .zero
    
    var axisAlign: Align = .center
    
    private var _axisPoint: CGPoint = .zero
    var axisPoint: CGPoint {
        get { return _axisPoint == Axis.center ? CGPoint(x: (collectionView?.bounds.width ?? 0) / 2, y: _axisPoint.y) : _axisPoint }
        set { _axisPoint = newValue }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }
        delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        
        attributesCache.removeAll(keepingCapacity: true)
        
        // Init section inset
        collectionView.contentInset = calcContentInset(in: collectionView)
        // Set content size
        contentSize = CGSize(width: 0, height: collectionView.bounds.height)
        
        let sections = collectionView.numberOfSections
        (0 ..< sections).enumerated().forEach { (offset, section) in
            let items = collectionView.numberOfItems(inSection: section)
            
            // Add section left inset to content size
            contentSize.width += offset == sections - 1 && items > 0 ? sectionInset.left : 0
            
            (0 ..< items).forEach { item in
                let indexPath = IndexPath(row: item, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                let size = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? self.itemSize
                attribute.frame = CGRect(origin: CGPoint(x: contentSize.width, y: (contentSize.height - size.height) / 2),
                                         size: size)
                
                attributesCache[indexPath] = attribute
                
                // Add item size to content width
                contentSize.width += size.width + (item < items - 1 ? minimumInteritemSpacing : 0)
            }
            
            // Add section right inset to content size
            contentSize.width += offset == 0 && items > 0 ? sectionInset.right : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesCache.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache[indexPath]
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
    private func calcContentInset(in collectionView: UICollectionView) -> UIEdgeInsets {
        var fIndexPath: IndexPath?
        var lIndexPath: IndexPath?
        
        let sections = collectionView.numberOfSections
        (0 ..< sections).forEach { section in
            let items = collectionView.numberOfItems(inSection: section)
            guard items > 0 else { return }
            
            lIndexPath = IndexPath(item: items - 1, section: section)
            if fIndexPath == nil {
                fIndexPath = IndexPath(item: 0, section: section)
            }
        }
        
        guard let firstIndexPath = fIndexPath, let lastIndexPath = lIndexPath else { return .zero }
        
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
