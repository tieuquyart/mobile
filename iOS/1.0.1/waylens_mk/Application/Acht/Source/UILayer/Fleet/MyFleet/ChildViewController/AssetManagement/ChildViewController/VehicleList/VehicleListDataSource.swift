//
//  VehicleListDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class VehicleListDataSource: TableArrayDataSource<VehicleProfile> {

    public convenience init(vehicles: [VehicleProfile]) {
        self.init(
            array: vehicles,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, _) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.imageView?.image = #imageLiteral(resourceName: "vehicle")
            cell.textLabel?.text = item.plateNo

            if !item.cameraSn.isEmpty {
                cell.detailTextLabel?.text = "\(NSLocalizedString("Camera", comment: "Camera")): \(item.cameraSn)"
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
    }

}

