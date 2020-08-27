//
//  NoticeListView.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class NoticeListView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "notice_title".localized
        return view
    }()
    
    let noticeTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = R.Color.clear
        view.separatorStyle = .none
        view.rowHeight = 60.adjust()
        
        // Register cell
        view.register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.name)
        
        return view
    }()
    
    // Empty view
    private let emptyLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = R.Color.codGray
        view.numberOfLines = 0
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.adjust()
        
        // Set attributed string
        view.attributedText = NSAttributedString(string: "notice_empty_title".localized, attributes: [.paragraphStyle: paragraphStyle])
        return view
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjust())
            make.trailing.equalToSuperview().inset(20.adjust()).priority(.high)
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    let loadingView: CommonLoading = {
        return CommonLoading()
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([noticeTableView, headerView, loadingView])
        noticeTableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
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
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
