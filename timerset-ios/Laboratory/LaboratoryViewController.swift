//
//  LaboratoryViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 13/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

enum LaboratoryRoute {
    case pageViewController
    case linkView
}

class LaboratoryViewController: BaseViewController {
    // MARK: view properties
    @IBOutlet weak var laboratoryTableView: UITableView!
    
    // MARK: properties
    private var menus: [BaseTableItem] = []
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize menu list
        initMenus()
        initLaboratoryTableView()
        
        laboratoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    deinit {
        Logger.verbose("")
    }
    
    // MARK: initalize methods
    
    /**
     * initialize menu items
     */
    private func initMenus() {
        menus.append(BaseTableItem(title: "Pager View Controller"))
        menus.append(BaseTableItem(title: "Link View"))
    }
    
    /**
     * initizlize setting table view datasource & delegate
     */
    private func initLaboratoryTableView() {
        // set setting menu table view datasource
        Observable.just(menus)
            .bind(to: laboratoryTableView.rx.items(cellIdentifier: "UITableViewCell")) { index, menu, cell in
                cell.textLabel?.text = menu.title
            }
            .disposed(by: disposeBag)
        
        // set setting menu select action
        laboratoryTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                // caution: ControlEvent doesn't complete. so you have to add [weak self]
                // when you want to use .subscribe about ControlEvent (ex. tap)
                guard let self = `self` else { return }
                
                guard let cell = self.laboratoryTableView.cellForRow(at: indexPath) else {
                    Logger.error("laboratory table view doesn't have cell at indexPath.")
                    return
                }
                // set cell selected property to false for disable select background
                cell.isSelected = false
                
                switch indexPath.row {
                case 0:
                    self.present(for: .pageViewController)
                case 1:
                    self.present(for: .linkView)
                default:
                    Logger.error("not valid index path.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: navigate methods
    private func present(for route: LaboratoryRoute) {
        switch route {
        case .pageViewController:
            Logger.verbose("presenting page view controller.")

            // load `laboratory` view controller
            let storyboard = UIStoryboard(name: "laboratory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PageViewController")
            
            // push view controller
            self.navigationController?.pushViewController(vc, animated: true)
        case .linkView:
            Logger.error("presenting isn't implemented.")
        }
    }
}
