//
//  LocalTimeSetView.swfit
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class LocalTimeSetView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.backButton.isHidden = true
        view.additionalButtons = [.history, .setting]
        view.title = "local_time_set_title".localized
        return view
    }()
    
    let timeSetCollectionView: UICollectionView = {
        let layout = JSCollectionViewLayout()
        layout.globalInset = UIEdgeInsets(top: 16.adjust(), left: 0, bottom: 20.adjust(), right: 0)
        layout.sectionInset = UIEdgeInsets(top: 10.adjust(), left: 0, bottom: 10.adjust(), right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = Constants.Color.clear
        view.contentInset = UIEdgeInsets(top: 0, left: 20.adjust(), bottom: 0, right: 20.adjust())
        
        // Register supplimentary view
        view.register(TimeSetHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.header.kind, withReuseIdentifier: TimeSetHeaderCollectionReusableView.name)
        view.register(TimeSetSectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: JSCollectionViewLayout.Element.sectionHeader.kind, withReuseIdentifier: TimeSetSectionHeaderCollectionReusableView.name)
        // Register cell
        view.register(TimeSetInduceCollectionViewCell.self, forCellWithReuseIdentifier: TimeSetInduceCollectionViewCell.name)
        view.register(TimeSetAllCollectionViewCell.self, forCellWithReuseIdentifier: TimeSetAllCollectionViewCell.name)
        view.register(SavedTimeSetBigCollectionViewCell.self, forCellWithReuseIdentifier: SavedTimeSetBigCollectionViewCell.name)
        view.register(SavedTimeSetSmallCollectionViewCell.self, forCellWithReuseIdentifier: SavedTimeSetSmallCollectionViewCell.name)
        
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set contraints of subviews
        addAutolayoutSubviews([timeSetCollectionView, headerView])
        timeSetCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide).priority(.high)
            } else {
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        headerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(20)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
