//
//  ConfirmHeader.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class ConfirmHeader: UIView {
    // MARK: - view properties
    
    // MARK: - properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: superview?.bounds.width ?? 0, height: 56.adjust())
    }
    
    // MARK: - constructor
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.Color.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        layer.border(edges: [.bottom], width: 1.adjust(), color: Constants.Color.silver)
    }
}
