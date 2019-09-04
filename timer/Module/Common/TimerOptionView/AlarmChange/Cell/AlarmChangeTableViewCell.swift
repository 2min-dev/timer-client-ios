//
//  AlarmChangeTableViewCell.swift
//  timer
//
//  Created by JSilver on 27/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift

class AlarmChangeTableViewCell: UITableViewCell {
    // MARK: - view properties
    private let playButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "btn_play"), for: .normal)
        return view
    }()
    
    let nameLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(12.adjust())
        view.textColor = Constants.Color.codGray
        return view
    }()
    
    private let checkImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(named: "icon_selected")
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        // Set constraint of subviews
        view.addAutolayoutSubviews([playButton, nameLabel, checkImageView])
        playButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(playButton.snp.width)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).inset(2.adjust())
            make.centerY.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(10.adjust())
            make.centerY.equalToSuperview()
            make.width.equalTo(36.adjust())
            make.height.equalTo(checkImageView.snp.width)
        }
        
        return view
    }()

    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let divider = UIView()
        divider.backgroundColor = Constants.Color.gallery
        
        // Set constraint of subviews
        contentView.addAutolayoutSubviews([containerView, divider])
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(52.adjust())
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        checkImageView.isHidden = !selected
    }
}
