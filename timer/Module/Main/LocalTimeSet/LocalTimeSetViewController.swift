//
//  LocalTimeSetViewController.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

typealias TimeSetSecionModel = SectionModel<Void, String>

class LocalTimeSetViewController: BaseViewController, View {
    // MARK: - view properties
    private var localTimeSetView: LocalTimeSetView { return view as! LocalTimeSetView }
    
    private var timeSetCollectionView: UICollectionView { return localTimeSetView.timeSetCollectionView }
    
    // MARK: - properties
    var coordinator: LocalTimeSetViewCoordinator
    
    private var sections: [TimeSetSecionModel] = [TimeSetSecionModel(model: Void(), items: [ "a", "b", "c", "d", "e", "f" ]),
                                                  TimeSetSecionModel(model: Void(), items: [ "a", "b", "c", "d", "e", "f" ])]
    
    // Time set datasource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<TimeSetSecionModel>(configureCell: { dataSource, collectionView, indexPath, cellType -> UICollectionViewCell in
        // Dequeue reusable cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.name, for: indexPath)
        cell.backgroundColor = .black
        return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
        // Dequeue supplementary view
        guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimeSetSectionCollectionReusableView.name, for: indexPath) as? TimeSetSectionCollectionReusableView else {
            fatalError()
        }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            // Set view type header
            supplementaryView.type = .header
            
        case UICollectionView.elementKindSectionFooter:
            // Set view type footer
            supplementaryView.type = .footer
            
        default:
            break
        }
        
        return supplementaryView
    })
    
    // MARK: - constructor
    init(coordinator: LocalTimeSetViewCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func loadView() {
        view = LocalTimeSetView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell & supplimentary view
        timeSetCollectionView.register(TimeSetSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TimeSetSectionCollectionReusableView.name)
        timeSetCollectionView.register(TimeSetSectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TimeSetSectionCollectionReusableView.name)
        timeSetCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.name)
        
        // Set table view delegate
        timeSetCollectionView.delegate = self
    }
    
    override func bind() {
        rx.viewWillAppear
            .take(1)
            .subscribe(onNext: {
                if let tabBar = (self.tabBarController as? MainViewController)?._tabBar {
                    // Adjust time set collection view size by tab bar
                    self.timeSetCollectionView.snp.updateConstraints { make in
                        make.bottom.equalToSuperview().inset(tabBar.bounds.height)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - bind
    func bind(reactor: LocalTimeSetViewReactor) {
        // MARK: action
        
        // MARK: state
        Observable<[TimeSetSecionModel]>.just(sections)
            .bind(to: timeSetCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    deinit {
        Logger.verbose()
    }
}

extension LocalTimeSetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 40.adjust())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 113.adjust())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let horizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return CGSize(width: collectionView.bounds.width - horizontalInset, height: 40.adjust())
    }
}
