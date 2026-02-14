//
//  TableViewFactory.swift
//  Acht
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TableViewFactory {

    class func makeGroupedTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.estimatedSectionHeaderHeight = 0.001
        tableView.estimatedSectionFooterHeight = 0.001
        return tableView
    }

    class func makePlainTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.estimatedSectionHeaderHeight = 0.001
        tableView.estimatedSectionFooterHeight = 0.001
        return tableView
    }
}
