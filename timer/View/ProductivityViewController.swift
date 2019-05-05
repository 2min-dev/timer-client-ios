//
//  ProductivityViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class ProductivityViewController: BaseViewController, View {
    // MARK: view properties
    private var timerSetView: ProductivityView { return self.view as! ProductivityView }
    
    // MARK: properties
    var coordinator: ProductivityViewCoordinator!
    
    // MARK: ### lifecycle ###
    override func loadView() {
        self.view = ProductivityView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ### reactor bind ###
    func bind(reactor: ProductivityViewReactor) {
        // MARK: action
        
        // MARK: state
    }
    
    deinit {
        Logger.verbose("")
    }
}
