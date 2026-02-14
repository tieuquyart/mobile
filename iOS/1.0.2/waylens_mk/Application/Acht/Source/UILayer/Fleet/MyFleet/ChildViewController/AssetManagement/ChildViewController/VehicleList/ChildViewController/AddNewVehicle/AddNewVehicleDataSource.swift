//
//  AddNewVehicleDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class AddNewVehicleDataSource: TableArrayDataSource<StandardTableViewCellViewModel> {

    public enum Rows: Int {
        case plateNumber
        case vehicleModel
        case driver
        case bindCamera
    }

    public convenience init(items: [StandardTableViewCellViewModel]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({(indexPath) in
                    switch indexPath.row {
                    case Rows.plateNumber.rawValue, Rows.vehicleModel.rawValue, Rows.driver.rawValue:
                        return 60.0
                    case Rows.bindCamera.rawValue:
                        return 80.0
                    case items.count - 1: // add new camera
                        return 60.0
                    default: // camera item
                        return 44.0
                    }
                }),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                switch indexPath.row {
                case Rows.plateNumber.rawValue, Rows.vehicleModel.rawValue, Rows.driver.rawValue:
                    return .Class(cellStyle: .value1)
                case Rows.bindCamera.rawValue:
                    return .Class(cellStyle: .subtitle)
                default:
                    return .Class(cellStyle: .default)
                }
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            switch indexPath.row {
            case Rows.plateNumber.rawValue, Rows.vehicleModel.rawValue, Rows.driver.rawValue:
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            default:
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }

            cell.imageView?.image = item.image
            cell.textLabel?.text = item.text
            cell.detailTextLabel?.text = item.detail
        }
    }

}

