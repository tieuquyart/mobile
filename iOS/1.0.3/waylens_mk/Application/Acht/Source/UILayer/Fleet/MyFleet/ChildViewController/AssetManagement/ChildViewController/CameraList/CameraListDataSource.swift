//
//  CameraListDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class CameraListDataSource: TableArrayDataSource<CameraProfile> {

    public convenience init(cameras: [CameraProfile]) {
        self.init(
            array: cameras,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, _) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.imageView?.image = #imageLiteral(resourceName: "camera_4g")
            cell.textLabel?.text = item.cameraSn

            if item.simState == .activated {
                if item.isBind {
                    cell.detailTextLabel?.text = String(format: NSLocalizedString("xx used in this month", comment: "%@ used in this month"), String.fromBytes(item.dataUsage * 1024, countStyle: .binary))
                } else {
                    cell.detailTextLabel?.text = NSLocalizedString("Not Bound", comment: "Not Bound")
                }
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Not Actived", comment: "Not Actived")
            }
        }
    }

}

