//
//  PresetViewController.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class PresetViewController: BaseHeaderViewController, ViewControllable, View {
    // MARK: - view properties
    private var presetView: PresetView { view as! PresetView }
    
    override var headerView: CommonHeader { presetView.headerView }
    
    private var timeSetCollectionView: UICollectionView { presetView.timeSetCollectionView }
    
    private var loadingView: CommonLoading { presetView.loadingView }
    
    // MARK: - properties
    var coordinator: PresetViewCoordinator
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<PresetSectionModel>(configureCell: { dataSource, collectionView, indexPath, reactor -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmaredTimeSetCollectionViewCell.name, for: indexPath) as? BookmaredTimeSetCollectionViewCell else { fatalError() }
        cell.reactor = reactor
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        switch kind {
        case JSCollectionViewLayout.Element.header.kind:
            // Global header
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name, for: indexPath) as? TimeSetHeaderCollectionReusableView else { fatalError() }
            supplementaryView.titleLabel.text = "preset_header_title".localized
            return supplementaryView
            
        default:
            fatalError()
        }
    })
    
    // MARK: - constructor
    init(coordinator: PresetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = PresetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register supplimentary view
        timeSetCollectionView.register(TimeSetHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name)
        // Register cell
        timeSetCollectionView.register(BookmaredTimeSetCollectionViewCell.self, forCellWithReuseIdentifier: BookmaredTimeSetCollectionViewCell.name)
        
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
    
    func bind(reactor: PresetViewReactor) {
        // MARK: action
        rx.viewWillAppear
            .map { .refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timeSetCollectionView.rx.itemSelected
            .withLatestFrom(reactor.state.map { $0.sections }, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] in
                let timeSetItem = $1[$0.section].items[$0.item].timeSetItem
                _ = self?.coordinator.present(for: .timeSetDetail(timeSetItem), animated: true)
            })
            .disposed(by: disposeBag)
        
        // MARK: state
        // Preset section
        reactor.state
            .filter { $0.shouldSectionReload }
            .map { $0.sections }
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // Loading
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isLoading)
            .disposed(by: disposeBag)
        
        // Error
        reactor.state
            .map { $0.error }
            .distinctUntilChanged()
            .compactMap { $0.value }
            .subscribe(onNext: { Logger.error($0) })
            .disposed(by: disposeBag)
    }
    
    // MARK: - action method
    func handleHeaderAction(_ action: CommonHeader.Action) {
        switch action {
        case .history:
            _ = coordinator.present(for: .history, animated: true)
            
        case .setting:
            _ = coordinator.present(for: .setting, animated: true)
            
        default:
            break
        }
    }
    
    // MARK: - state method
    
    deinit {
        Logger.verbose()
    }
}

extension PresetViewController: JSCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.adjust()
    }
    
    func referenceSizeForHeader(in collectionView: UICollectionView, layout collectionViewLayout: JSCollectionViewLayout) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 87.adjust())
    }
}
