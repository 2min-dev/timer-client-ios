//
//  JSCollectionViewLayout.swift
//  timer
//
//  Created by JSilver on 09/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

@objc protocol JSCollectionViewDelegateLayout: UICollectionViewDelegateFlowLayout {
    /// Asks the delegate for the size of the header view in the collection view.
    @objc optional func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize
    
    /// Asks the delegate for the size of the footer view in the collection view.
    @objc optional func referenceSizeForFooter(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize
    
    /// Asks the delegate for visibility of the header view in the specified section.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout, visibleHeaderInSection section: Int) -> Bool
    
    /// Asks the delegate for visibility of the footer view in the specified section.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout, visibleFooterInSection section: Int) -> Bool
    
    /// Asks the delegate for visibility of the header view in the collection view.
    @objc optional func headerVisible(collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> Bool
    
    /// Asks the delegate for visibility of the footer view in the collection view.
    @objc optional func footerVisible(collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> Bool
}

/// Global header & footer added flow layout
class JSCollectionViewLayout: UICollectionViewFlowLayout {
    enum Element: String, CaseIterable {
        case header
        case footer
        case sectionHeader
        case sectionFooter
        case cell
        
        var kind: String {
            return self.rawValue
        }
    }
    
    // MARK: - properties
    private var attributesCache: [Element: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
    
    private var oldBounds: CGRect = .zero
    private var contentSize: CGSize = .zero
    
    private var itemPosition: CGPoint = .zero
    private var maxRowPosition: CGFloat = 0
    
    // Flow layout delegate
    weak var delegate: JSCollectionViewDelegateLayout?
    
    // Supplementary view size properties
    var globalHeaderReferenceSize: CGSize = .zero
    var globalFooterReferenceSize: CGSize = .zero
    
    // Supplementary view visible properties
    var headerVisible: Bool = true
    var footerVisible: Bool = true
    var sectionHeaderVisible: Bool = true
    var sectionFooterVisible: Bool = true
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        // Get delegate
        let delegate = getDelegate()
        
        // Init layout & attributes cache
        prepareLayout(collectionView: collectionView)
        Element.allCases.forEach { attributesCache[$0] = [:] }
        
        // Global header
        if delegate?.headerVisible?(collectionView: collectionView, layout: self) ?? headerVisible {
            prepareElement(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.header.kind,
                                                            with: IndexPath(item: 0, section: 0)),
                           size: delegate?.referenceSizeForHeader?(in: collectionView,
                                                                   layout: self) ?? globalHeaderReferenceSize,
                           type: Element.header)
        }
        
        let sectionCount = collectionView.numberOfSections
        (0 ..< sectionCount).forEach { section in
            // Section header
            if delegate?.collectionView?(collectionView, layout: self, visibleHeaderInSection: section) ?? sectionHeaderVisible {
                prepareElement(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.sectionHeader.kind,
                                                                with: IndexPath(item: 0, section: section)),
                               size: delegate?.collectionView?(collectionView,
                                                               layout: self,
                                                               referenceSizeForHeaderInSection: section) ?? headerReferenceSize,
                               type: Element.sectionHeader)
            }
            
            // Item
            let itemCount = collectionView.numberOfItems(inSection: section)
            (0 ..< itemCount).forEach { item in
                let indexPath = IndexPath(item: item, section: section)
                prepareElement(UICollectionViewLayoutAttributes(forCellWith: indexPath),
                               size: delegate?.collectionView?(collectionView,
                                                               layout: self,
                                                               sizeForItemAt: indexPath) ?? itemSize,
                               type: .cell)
            }
            
            // Section footer
            if delegate?.collectionView?(collectionView, layout: self, visibleFooterInSection: section) ?? sectionFooterVisible {
                prepareElement(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.sectionFooter.kind,
                                                                with: IndexPath(item: 1, section: section)),
                               size: delegate?.collectionView?(collectionView,
                                                               layout: self,
                                                               referenceSizeForFooterInSection: section) ?? footerReferenceSize,
                               type: Element.sectionFooter)
            }
        }
        
        // Global footer
        if delegate?.footerVisible?(collectionView: collectionView, layout: self) ?? footerVisible {
            prepareElement(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.header.kind,
                                                            with: IndexPath(item: 0, section: 0)),
                           size: delegate?.referenceSizeForFooter?(in: collectionView,
                                                                   layout: self) ?? globalFooterReferenceSize,
                           type: Element.footer)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []
        attributesCache.forEach {
            visibleAttributes.append(contentsOf: ($0.value.filter { $0.value.frame.intersects(rect) }.map { $0.value }))
        }
        
        return visibleAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesCache[.cell]?[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            attributesCache.removeAll(keepingCapacity: true)
        }
        return true
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case Element.header.kind:
            return attributesCache[.header]?[indexPath]
            
        case Element.footer.kind:
            return attributesCache[.footer]?[indexPath]
            
        case Element.sectionHeader.kind:
            return attributesCache[.sectionHeader]?[indexPath]
            
        case Element.sectionFooter.kind:
            return attributesCache[.sectionFooter]?[indexPath]
            
        default:
            return nil
        }
    }
    
    // MARK: - private method
    /// Get layout delegate
    private func getDelegate() -> JSCollectionViewDelegateLayout? {
        if let delegate = delegate {
            // Return set layout delegate
            return delegate
        }
        
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? JSCollectionViewDelegateLayout {
            // Return collection view delegate
            return delegate
        }
        
        return nil
    }
    
    /// Initialize properties for layout attributes
    private func prepareLayout(collectionView: UICollectionView) {
        // Init layout positioning property
        itemPosition = .zero
        maxRowPosition = 0
        
        oldBounds = collectionView.bounds
        
        // Init content size
        let contentInset = collectionView.contentInset
        contentSize = .zero
        contentSize.width = collectionView.bounds.width - (contentInset.left + contentInset.right)
    }
    
    /// Prepare element attribute for caching
    private func prepareElement(_ element: UICollectionViewLayoutAttributes, size: CGSize, type: Element) {
        guard size != .zero else { return }
        
        if type == .cell {
            // If element type is cell, calculate cell can enter space
            if itemPosition.x + size.width > contentSize.width {
                itemPosition = CGPoint(x: 0, y: contentSize.height + minimumLineSpacing)
            } else {
                itemPosition.x += minimumInteritemSpacing
            }
        } else {
            // Supplementary view occupies full width of collection view
            itemPosition = CGPoint(x: 0, y: contentSize.height)
        }
        
        if type == .sectionFooter {
            itemPosition.y += sectionInset.bottom
        }
        
        // Set element frame attribute
        let origin = itemPosition
        element.frame = CGRect(origin: origin, size: size)
        
        if type == .sectionHeader {
            itemPosition.y += sectionInset.top
        }
        
        itemPosition.x = element.frame.maxX
        contentSize.height = max(contentSize.height, element.frame.maxY)
        
        // Add attribute into cache
        attributesCache[type]?[element.indexPath] = element
    }
}
