//
//  TodayView.swift
//  widget
//
//  Created by Jeong Jin Eun on 17/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TodayView: UIView {
    let label: UILabel = {
        let view = UILabel()
        view.text = "Hello World~"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
