//
//  SettingView.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class SettingView: UIView {
    // MARK: view propeties
    let tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .grouped)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAutolayoutSubview(tableView)
        
        tableView.snp.makeConstraints({ make in
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
