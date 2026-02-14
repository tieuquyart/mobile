//
//  CameraDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public enum CameraProperty: Equatable {
    case cameraSN(String)
    case firmwareVersion(String)
    case model(String)
    case mountModel(String)
    case mountVersion(String)
    case iccid(String)

    var propertyName: String {
        switch self {
        case .cameraSN(let value):
            return value
        case .model:
            return NSLocalizedString("Model", comment: "Model")
        case .firmwareVersion:
            return NSLocalizedString("Firmware Version", comment: "Firmware Version")
        case .mountModel:
            return NSLocalizedString("Mount Model", comment: "Mount Model")
        case .mountVersion:
            return NSLocalizedString("Mount Version", comment: "Mount Version")
        case .iccid:
            return NSLocalizedString("ICCID", comment: "ICCID")
        }
    }

    public static func == (lhs: CameraProperty, rhs: CameraProperty) -> Bool {
        switch (lhs, rhs) {
        case (.cameraSN(let left), .cameraSN(let right)):
            return left == right
        case (.firmwareVersion(let left), .firmwareVersion(let right)):
            return left == right
        case (.model(let left), .model(let right)):
            return left == right
        case (.mountModel(let left), .mountModel(let right)):
            return left == right
        case (.mountVersion(let left), .mountVersion(let right)):
            return left == right
        case (.iccid(let left), .iccid(let right)):
            return left == right
        default:
            return false
        }
    }
}

public class CameraDataSource: TableArrayDataSource<CameraProperty> {

    public convenience init(items: [CameraProperty]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight(
                    { indexPath in
                        if indexPath.row == 0 {
                            return 90.0
                        }
                        return 60.0
                    }
                ),
//                TableSetting.shouldHighlightRow({ _ return false}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .value1)
        }
        ) { (cell, item, _) in
            TableViewCellFactory.configValue1StyleCell(cell)
            cell.accessoryType = .none

            switch item {
            case .firmwareVersion:
                cell.selectionStyle = .default
            default:
                cell.selectionStyle = .none
            }

            cell.textLabel?.text = item.propertyName

            switch item {
            case .cameraSN:
                cell.imageView?.image = #imageLiteral(resourceName: "camera_4g")
            case .model(let value),
                 .firmwareVersion(let value),
                 .mountVersion(let value),
                 .mountModel(let value),
                 .iccid(let value):
                cell.detailTextLabel?.text = value
            }

        }
    }

}

