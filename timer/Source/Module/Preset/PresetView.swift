//
//  PresetView.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PresetView: UIView {
    // MARK: - view properties
    let root: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
