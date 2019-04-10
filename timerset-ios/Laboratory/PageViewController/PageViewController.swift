//
//  PageViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    private let storyboardIdenfier = "laboratory"
    
    private var pages: [String] = ["FirstPageViewController", "SecondPageViewController", "ThirdPageViewController"]
    private var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        setViewControllers([loadViewController(identifier: pages[page])], direction: .forward, animated: true, completion: nil)
    }
    
    private func loadViewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: storyboardIdenfier, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // page view controller pre alloced both side view of current page.
    
    /**
     *  pre alloc view controller far two-step based on current page.
     *  If your the current pages state is B C(current) D, a page A will be alloced by this method when you swipe back.
     *  So when you end swipe gesture, the pages state is A B(current) C D(deinit)
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if page == 0 {
            return nil
        } else {
            page -= 1
            Logger.debug(page)
            return loadViewController(identifier: pages[page])
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if page == pages.count - 1 {
            return nil
        } else {
            page += 1
            Logger.debug(page)
            return loadViewController(identifier: pages[page])
        }
    }
}
