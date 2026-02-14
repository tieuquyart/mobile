//
//  UITableView+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/7/17.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MJRefresh

extension UITableView {

    func removeSeparatorOnLastCell() {
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
    }

    func setPullRefreshAction(_ target: Any, refreshAction: Selector, loadMoreAction: Selector? = nil) {
        mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: refreshAction)

        if let loadMoreAction = loadMoreAction {
            let footer = HNRefreshFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
        
            footer.triggerAutomaticallyRefreshPercent = 0.1
            mj_footer = footer
            mj_footer?.isHidden = true
        }
    }
    
    
    func setPullRefreshActionT(_ target: Any, refreshAction: Selector, loadMoreAction: Selector? = nil) {
       mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: refreshAction)

        if let loadMoreAction = loadMoreAction {
//            let footer = HNRefreshFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
            let footer = MJRefreshBackNormalFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
//            footer.triggerAutomaticallyRefreshPercent = 0.1
            mj_footer = footer
           // mj_footer?.isHidden = true
        }
    }
    
}


extension UICollectionView {

   

    func setPullRefreshAction(_ target: Any, refreshAction: Selector, loadMoreAction: Selector? = nil) {
        mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: refreshAction)

        if let loadMoreAction = loadMoreAction {
            let footer = HNRefreshFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
        
            footer.triggerAutomaticallyRefreshPercent = 0.1
            mj_footer = footer
            mj_footer?.isHidden = true
        }
    }
    
    
    func setPullRefreshActionT(_ target: Any, refreshAction: Selector, loadMoreAction: Selector? = nil) {
       mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: refreshAction)

        if let loadMoreAction = loadMoreAction {
//            let footer = HNRefreshFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
            let footer = MJRefreshBackNormalFooter(refreshingTarget: target, refreshingAction: loadMoreAction)
//            footer.triggerAutomaticallyRefreshPercent = 0.1
            mj_footer = footer
           // mj_footer?.isHidden = true
        }
    }
    
}
