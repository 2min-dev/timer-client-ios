//
//  IntroView.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import SnapKit

class IntroView: UIView {
    // MARK: - view propeties
    let splashIconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon_app"))
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.alabaster
        
        addAutolayoutSubview(splashIconImageView)
        
        splashIconImageView.snp.makeConstraints({ make in
            if #available(iOS 11.0, *) {
                make.center.equalTo(safeAreaLayoutGuide)
            } else {
                make.center.equalToSuperview()
            }
            make.width.equalTo(60.adjust())
            make.height.equalTo(splashIconImageView.snp.width)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
