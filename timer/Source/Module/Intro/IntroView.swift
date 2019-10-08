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
    let view: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
        
        addAutolayoutSubview(view)
        
        view.snp.makeConstraints({ make in
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
