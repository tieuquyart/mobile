//
//  CollectionArrayDataSource.swift
//  GenericDataSource
//
//  Created by Andrea Prearo on 4/20/17.
//  Copyright © 2017 Andrea Prearo. All rights reserved.
//

import UIKit

open class TableArrayDataSource<T>: TableDataSource<ArrayDataProvider<T>>
{
    public convenience init(
        array: [T],
        tableSettings: [TableSetting],
        cellInstantiator: @escaping CellInstantiator,
        cellConfigurator: @escaping CellConfigurator<T>
        ) {
        self.init(
            array: [array],
            tableSettings: tableSettings,
            cellInstantiator: cellInstantiator,
            cellConfigurator: cellConfigurator
        )
    }

    public init(
        array: [[T]],
        tableSettings: [TableSetting],
        cellInstantiator: @escaping CellInstantiator,
        cellConfigurator: @escaping CellConfigurator<T>
        ) {
        let provider = ArrayDataProvider(array: array)
        super.init(
            provider: provider,
            tableSettings: tableSettings,
            cellInstantiator: cellInstantiator,
            cellConfigurator: cellConfigurator
        )
    }

    // MARK: - Public Methods
    public func item(at indexPath: IndexPath) -> T? {
        return provider.item(at: indexPath)
    }

    public func updateItem(at indexPath: IndexPath, value: T) {
        provider.updateItem(at: indexPath, value: value)
    }
}
