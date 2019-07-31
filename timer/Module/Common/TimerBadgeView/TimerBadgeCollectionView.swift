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

protocol ReactiveDataSource: View {
    associatedtype SectionType: SectionModelType
}

typealias TimerBadgeSectionModel = SectionModel<Void, TimerBadgeCellType>

class TimerBadgeCollectionView: UICollectionView, ReactiveDataSource {
    typealias SectionType = TimerBadgeSectionModel
    
    // MARK: - constants
    static let centerAnchor = CGPoint(x: -1, y: -1)
    
    // MARK: - properties
    private lazy var _dataSource = RxCollectionViewSectionedReloadDataSource<SectionType>(configureCell: { (dataSource, collectionView, indexPath, cellType) -> UICollectionViewCell in
        switch cellType {
        case let .regular(reactor):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeCollectionViewCell.ReuseableIdentifier, for: indexPath) as! TimerBadgeCollectionViewCell
            // Send action into reactor for initialize state
            reactor.action.onNext(.setoOtionVisible(self.isOptionButtonVisible))
            cell.reactor = reactor
            
            return cell
        case .add:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimerBadgeAddCollectionViewCell.ReuseableIdentifier, for: indexPath)
            return cell
        }
    })
    
    // Timer badge option button visible/hidden property
    var isOptionButtonVisible = true
    
    // Timer badge extra cell config property
    fileprivate var extraCell: TimerBadgeCellType?
    fileprivate var shouldShowExtraCell: ([TimerInfo], TimerBadgeCellType) -> Bool = { _, _ in
        return true
    }
    
    var anchorPoint = CGPoint(x: 0, y: 0)
    var isAutoScroll = true
    
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
    }
    
    func bind(reactor: TimerBadgeViewReactor) {
        // MARK: action
        rx.itemSelected
            .map { Reactor.Action.selectBadge($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: state
        reactor.state
            .map { $0.sections }
            .bind(to: rx.items(dataSource: _dataSource))
            .disposed(by: disposeBag)
    
        reactor.state
            .map { $0.selectedIndexPath }
            .distinctUntilChanged()
            .filter { _ in self.isAutoScroll }
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in self?.moveToSelectedBadge(indexPath: indexPath) })
            .disposed(by: disposeBag)
    }
    
    /**
     Animate that move cell to anchor point
     
     - parameters:
        - indexPath: Index path of selected cell
     */
    private func moveToSelectedBadge(indexPath: IndexPath?) {
        guard let indexPath = indexPath,
            let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellOffset: CGFloat // Current cell offset in collection view
        let diff: CGFloat // Deference about between cell offset and anchor point
        
        let index = CGFloat(indexPath.row)
        switch layout.scrollDirection {
        case .horizontal:
            // Horizontal scroll
            cellOffset = index * layout.itemSize.width + index * layout.minimumInteritemSpacing
            if self.anchorPoint == TimerBadgeCollectionView.centerAnchor {
                diff = self.bounds.width / 2 - layout.itemSize.width / 2
            } else {
                diff = self.anchorPoint.x
            }
        case .vertical:
            // Vertical scroll
            cellOffset = index * layout.itemSize.height + index * layout.minimumLineSpacing
            if self.anchorPoint == TimerBadgeCollectionView.centerAnchor {
                diff = self.bounds.height / 2 - layout.itemSize.height / 2
            } else {
                diff = self.anchorPoint.y
            }
        @unknown default:
            fatalError()
        }
        
        // Animate scroll to anchor point
        UIView.animate(withDuration: 1) {
            self.setContentOffset(CGPoint(x: cellOffset - diff, y: 0), animated: true)
        }
    }
    
    // MARK: - public method
    // Set timer badge extra cell config
    func setExtraCell(_ extraCell: TimerBadgeCellType, shouldShowExtraCell: (([TimerInfo], TimerBadgeCellType) -> Bool)?) {
        self.extraCell = extraCell
        if let shouldShowExtraCell = shouldShowExtraCell {
            self.shouldShowExtraCell = shouldShowExtraCell
        }
    }
}

extension TimerBadgeCollectionView: UICollectionViewDelegate {
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
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        
        switch layout.scrollDirection {
        case .horizontal:
            // Horizontal scroll
            if anchorPoint == TimerBadgeCollectionView.centerAnchor {
                return collectionView.bounds.width / 2 - cell.bounds.width / 2
            } else {
                return isFirst ? anchorPoint.x : collectionView.bounds.width - (cell.bounds.width + anchorPoint.x)
            }
        case .vertical:
            // Vertical scroll
            if anchorPoint == TimerBadgeCollectionView.centerAnchor {
                return collectionView.bounds.height / 2 - cell.bounds.height / 2
            } else {
                return isFirst ? anchorPoint.y : collectionView.bounds.height - (cell.bounds.height + anchorPoint.y)
            }
        @unknown default:
            fatalError()
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
// TODO: Check memory leak
extension Reactive where Base: TimerBadgeCollectionView {
    var items: Binder<[TimerInfo]> {
        return Binder(base.self) { _, timers in
            Observable.just(timers)
                .map {
                    if let extraCell = self.base.extraCell, self.base.shouldShowExtraCell(timers, extraCell) {
                        return Base.Reactor.Action.updateTimers($0, extraCell)
                    }
                    return Base.Reactor.Action.updateTimers($0, nil)
                }
                .bind(to: self.base.reactor!.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    var timer: Binder<TimeInterval> {
        return Binder(base.self) { _, timeInterval in
            Observable.just(timeInterval)
                .map { Base.Reactor.Action.updateTimer($0) }
                .bind(to: self.base.reactor!.action)
                .disposed(by: self.base.disposeBag)
        }
    }
    
    var badgeSelected: ControlEvent<(IndexPath, TimerBadgeCellType)> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))
            .map { a -> (IndexPath, TimerBadgeCellType) in
                let indexPath = a[1] as! IndexPath
                let cellType = self.base.reactor!.currentState.sections[0].items[indexPath.row]
                
                return (a[1] as! IndexPath, cellType)
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
