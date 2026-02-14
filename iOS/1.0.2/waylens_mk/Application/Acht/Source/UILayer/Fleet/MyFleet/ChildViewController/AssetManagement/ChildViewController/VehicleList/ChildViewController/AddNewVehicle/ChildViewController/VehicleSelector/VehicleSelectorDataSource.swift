//
//  VehicleSelectorDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxCocoa
import RxSwift

public class VehicleSelectorDataSource: TableArrayDataSource<VehicleProfile> {

    public var selectedIndexPath: IndexPath? = nil
    public var selectedItem: VehicleProfile? {
        if let selectedIndexPath = selectedIndexPath {
            return provider.items.first?[selectedIndexPath.row]
        }
        return nil
    }

    public convenience init(items: [VehicleProfile], selectedIndexPath: IndexPath? = nil) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 44.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, _) in
            TableViewCellFactory.configValue1StyleCell(cell)

            cell.selectionStyle = .none
            cell.accessoryType = .none

            cell.imageView?.contentMode = .center
            cell.textLabel?.text = item.plateNo
        }

        self.selectedIndexPath = selectedIndexPath
        self.appendCellConfigurator { [weak self] (cell, item, _) in
            guard let strongSelf = self else {
                return
            }

            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            // update selection indicator
            if let firstIndex = items.firstIndex(of: item), firstIndex == strongSelf.selectedIndexPath?.row {
                cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
            } else {
                cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
            }
        }

    }

}
