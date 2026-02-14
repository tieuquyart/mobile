//
//  CalibrationVehicleInfoContentView.swift
//  Fleet
//
//  Created by forkon on 2020/8/6.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class CalibrationVehicleInfoContentView: UIView {

    private(set) lazy var tableView: UITableView = { [weak self] in
        let tableView = TableViewFactory.makePlainTableView()
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tableView.frame = bounds.insetBy(dx: -12.0, dy: 0.0)
    }
}
