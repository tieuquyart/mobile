//
//  CameraDetailDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class CameraDetailDataSource: TableArrayDataSource<StandardTableViewCellViewModel> {

    public convenience init(items: [StandardTableViewCellViewModel], firmwareVersionRow: Int? = nil) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 60.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .value1)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configValue1StyleCell(cell)

            cell.accessoryType = .none

            if let firmwareVersionRow = firmwareVersionRow, indexPath.row == firmwareVersionRow {
                cell.selectionStyle = .default
            } else {
                cell.selectionStyle = .none
            }

            cell.textLabel?.text = item.text
            cell.detailTextLabel?.text = item.detail
        }
    }

}

