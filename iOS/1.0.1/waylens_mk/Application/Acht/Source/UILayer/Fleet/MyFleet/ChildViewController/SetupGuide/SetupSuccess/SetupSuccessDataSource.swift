//
//  SetupSuccessDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class SetupSuccessDataSource: TableArrayDataSource<StandardTableViewCellViewModel> {

    public convenience init(vehicle: VehicleProfile? = nil, driver: FleetMember? = nil, camera: CameraProfile? = nil) {
        self.init(items:
            [
                StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Plate Number", comment: "Plate Number"), detail: vehicle?.plateNo),
                StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Vehicle Model", comment: "Vehicle Model"), detail: vehicle?.type),
                StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Driver", comment: "Driver"), detail: driver?.name),
                StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Bound Camera", comment: "Bound Camera"), detail: camera?.cameraSn),
            ]
        )
    }

    public convenience init(items: [StandardTableViewCellViewModel]) {
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

            cell.selectionStyle = .none
            cell.accessoryType = .none

            cell.textLabel?.text = item.text
            cell.detailTextLabel?.text = item.detail
        }
    }

}

