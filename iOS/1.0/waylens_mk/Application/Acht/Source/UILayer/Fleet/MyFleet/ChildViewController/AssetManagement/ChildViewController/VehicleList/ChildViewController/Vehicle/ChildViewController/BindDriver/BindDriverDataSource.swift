//
//  BindDriverDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class BindDriverDataSource: TableArrayDataSource<FleetMember> {

    public var selectedIndexPath: IndexPath? = nil
    public var selectedItem: FleetMember? {
        if let selectedIndexPath = selectedIndexPath {
            return provider.items.first?[selectedIndexPath.row]
        }
        return nil
    }

    public convenience init(items: [FleetMember], selectedIndexPath: IndexPath? = nil) {
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
            cell.textLabel?.text = item.name
        }

        self.selectedIndexPath = selectedIndexPath
        self.appendCellConfigurator { [weak self] (cell, item, _) in
            // update selection indicator

            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            if let firstIndex = items.firstIndex(of: item), firstIndex == self?.selectedIndexPath?.row {
                cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
            } else {
                cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
            }
        }
    }
}
