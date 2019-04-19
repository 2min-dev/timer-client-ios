//
//  TodayView.swift
//  widget
//
//  Created by Jeong Jin Eun on 17/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import SnapKit

class TodayView: UIView {
    let label: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = Constants.Font.NanumSquareRoundR.withSize(18.adjust())
        view.textColor = Constants.Color.gray
        view.text = "widget_preparing_title".localized
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviewForAutoLayout(label)
        
        label.snp.makeConstraints({ make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
