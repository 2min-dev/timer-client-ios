//
//  TimeSetEditView.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class TimeSetEditView: UIView {
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