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
    static let ReuseableIdentifier = "AlarmChangeTableViewCell"
    
    // MARK: - view properties
    private let playButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .red
        return view
    }()
    
    let nameLabel: UILabel = {
        let view = UILabel()
        view.font = Constants.Font.Regular.withSize(13.adjust())
        return view
    }()
    
    private let checkImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .green
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [playButton, nameLabel, checkImageView])
        view.axis = .horizontal
        
        // Set constarint of subviews
        playButton.snp.makeConstraints { make in
            make.width.equalTo(playButton.snp.height)
        }
        
        checkImageView.snp.makeConstraints { make in
            make.width.equalTo(40.adjust())
        }
        
        return view
    }()
    
    // MARK: - properties
    var disposeBag: DisposeBag = DisposeBag()

    // MARK: - constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addAutolayoutSubview(contentStackView)
        // Set constarint of subviews
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50.adjust())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        checkImageView.isHidden = !selected
    }
}
