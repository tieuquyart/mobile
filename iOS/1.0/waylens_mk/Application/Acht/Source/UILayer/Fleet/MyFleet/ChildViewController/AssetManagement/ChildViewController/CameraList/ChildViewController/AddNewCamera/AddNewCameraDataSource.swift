//
//  AddNewCameraDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class AddNewCameraDataSource: TableArrayDataSource<Any> {

    public convenience init(items: [Any]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 60.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, _) in

        }
    }

}

