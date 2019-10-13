//
//  TeamInfoView.swift
//  timer
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TeamInfoView: UIView {
    // MARK: - view properties
    let headerView: CommonHeader = {
        let view = CommonHeader()
        view.title = "team_info_title".localized
        return view
    }()
    
    private let infoLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        view.numberOfLines = 0
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12.adjust()
        
        // Set attributed string
        view.attributedText = NSAttributedString(string: "team_info_service_description".localized, attributes: [.paragraphStyle: paragraphStyle])
        
        return view
    }()
    
    let emailLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(15.adjust())
        view.textColor = Constants.Color.codGray
        view.text = Constants.email
        return view
    }()
    
    let copyButton: UIButton = {
        let view = UIButton()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.titleLabel?.font = Constants.Font.Regular.withSize(12.adjust())
        view.titleLabel?.textColor = Constants.Color.codGray
        view.setAttributedTitle(NSAttributedString(string: "team_info_email_copy_title".localized, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        return view
    }()
    
    private lazy var contactView: UIView = {
        let view = UIView()
        
        let topDivider = UIView()
        topDivider.backgroundColor = Constants.Color.silver
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = Constants.Color.silver
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([topDivider, emailLabel, copyButton, bottomDivider])
        topDivider.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30.adjust())
            make.trailing.equalTo(copyButton.snp.leading).inset(-5.adjust())
            make.centerY.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30.adjust())
            make.centerY.equalToSuperview()
        }
        
        bottomDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        view.addAutolayoutSubviews([infoLabel, contactView])
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(22.adjust())
            make.leading.equalToSuperview().inset(30.adjust())
            make.trailing.equalToSuperview().inset(30.adjust())
        }

        contactView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).inset(-22.adjust())
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(40.adjust())
            make.height.equalTo(60.adjust())
        }
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delaysContentTouches = false
        
        // Set constraint of subviews
        view.addAutolayoutSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().priorityLow()
        }
        
        return view
    }()
    
    // MARK: - properties
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        // Set constraint of subviews
        addAutolayoutSubviews([scrollView, headerView])
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
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
