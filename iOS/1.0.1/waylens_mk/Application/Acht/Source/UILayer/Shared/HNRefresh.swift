//
//  HNRefresh.swift
//  Acht
//
//  Created by Chester Shen on 8/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import MJRefresh

class HNRefreshFooter: MJRefreshAutoNormalFooter {
    override func endRefreshingWithNoMoreData() {
        super.endRefreshingWithNoMoreData()
        self.isHidden = true
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        self.isHidden = false
    }
}
