//
//  MyFleetSection.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MyFleetSectionItem {
    var image: UIImage? = nil
    var title: String
    let cellType: UITableViewCell.Type
    let cellHeight: CGFloat
    let cellStyle: UITableViewCell.CellStyle
    let detailViewControllerClass: UIViewController.Type?

    init(
        image: UIImage?,
        title: String,
        cellType: UITableViewCell.Type = UITableViewCell.self,
        cellHeight: CGFloat = 60.0,
        cellStyle: UITableViewCell.CellStyle = .default,
        detailViewControllerClass: UIViewController.Type?
        ) {
        self.image = image
        self.title = title
        self.cellType = cellType
        self.cellHeight = cellHeight
        self.cellStyle = cellStyle
        self.detailViewControllerClass = detailViewControllerClass
    }
}

class TableViewSection {
    let headerHeight: CGFloat
    var items: [MyFleetSectionItem]

    init(items: [MyFleetSectionItem], headerHeight: CGFloat = 12.0) {
        self.items = items
        self.headerHeight = headerHeight
    }
}

