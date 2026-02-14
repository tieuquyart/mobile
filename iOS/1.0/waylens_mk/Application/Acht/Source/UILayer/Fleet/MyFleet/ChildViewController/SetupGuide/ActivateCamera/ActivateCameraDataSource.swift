//
//  ActivateCameraDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class ActivateCameraDataSource: TableArrayDataSource<StandardTableViewCellViewModel> {

    public convenience init(camera: CameraProfile?) {
        self.init(items: [StandardTableViewCellViewModel(image: #imageLiteral(resourceName: "camera_4g"), text: NSLocalizedString("Camera S/N", comment: "Camera S/N"), detail: camera?.cameraSn)])
    }

    public convenience init(items: [StandardTableViewCellViewModel]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 100.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .value1)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configValue1StyleCell(cell)

            cell.accessoryType = .none
            cell.selectionStyle = .none

            cell.imageView?.image = item.image
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.textLabel?.text = item.text
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.semanticColor(.tint(.primary))
            cell.detailTextLabel?.text = item.detail
        }
    }

}

