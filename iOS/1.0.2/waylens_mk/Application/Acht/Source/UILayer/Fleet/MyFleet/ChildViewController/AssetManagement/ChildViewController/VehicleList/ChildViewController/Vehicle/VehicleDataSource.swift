//
//  VehicleDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public enum VehicleProperty: Equatable {
    case driver(String?)
    case model(String)
    case plateNumber(String)
    case camera(String)

    var propertyName: String {
        switch self {
        case .driver:
            return NSLocalizedString("Driver", comment: "Driver")
        case .model:
            return NSLocalizedString("Model", comment: "Model")
        case .plateNumber(let value):
            return value
        case .camera:
            return NSLocalizedString("Camera", comment: "Camera")
        }
    }

    public static func == (lhs: VehicleProperty, rhs: VehicleProperty) -> Bool {
        switch (lhs, rhs) {
        case (.driver(let left), .driver(let right)):
            return left == right
        case (.model(let left), .model(let right)):
            return left == right
        case (.plateNumber(let left), .plateNumber(let right)):
            return left == right
        case (.camera(let left), .camera(let right)):
            return left == right
        default:
            return false
        }
    }
}

public class VehicleDataSource: TableArrayDataSource<VehicleProperty> {

    public convenience init(items: [VehicleProperty]) {
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
                TableSetting.sectionHeaderHeight({ _ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .value1)
        }
        ) { (cell, item, _) in
            TableViewCellFactory.configValue1StyleCell(cell)
            cell.selectionStyle = .default

            cell.textLabel?.text = item.propertyName

            switch item {
            case .plateNumber:
                cell.imageView?.image = #imageLiteral(resourceName: "vehicle")
                cell.selectionStyle = .none
                cell.accessoryType = .none
            case .driver(let value):
                cell.detailTextLabel?.text = value
                cell.accessoryType = .disclosureIndicator
            case .model(let value):
                cell.detailTextLabel?.text = value
                cell.accessoryType = .disclosureIndicator
            case .camera(let cameraSN):
                if cameraSN.isEmpty {
                    let actionButton = UIButton(type: .custom)
                    actionButton.set(
                        title: NSLocalizedString("Bind", comment: "Bind"),
                        titleFont: UIFont.systemFont(ofSize: 14.0),
                        titleColor: UIColor.semanticColor(.tint(.primary)),
                        imageOnTitleLeft: nil,
                        imageOnTitleRight: nil,
                        margins: UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 35.0),
                        borderColor: UIColor.semanticColor(.tint(.primary)),
                        cornerRadius: UIButton.CornerRadius.halfHeight
                    )
                    actionButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .normal)
                    actionButton.isUserInteractionEnabled = false

                    cell.accessoryView = actionButton
                } else {
                    let actionButton = UIButton(type: .custom)
                    actionButton.set(
                        title: cameraSN,
                        titleFont: UIFont.systemFont(ofSize: 14.0),
                        titleColor: UIColor.semanticColor(.tint(.primary)),
                        imageOnTitleLeft: nil,
                        imageOnTitleRight: nil,
                        margins: UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 35.0),
                        borderColor: UIColor.semanticColor(.tint(.primary)),
                        cornerRadius: UIButton.CornerRadius.halfHeight
                    )
                    actionButton.isUserInteractionEnabled = false

                    cell.accessoryView = actionButton
                }
            }
        }
    }

}

