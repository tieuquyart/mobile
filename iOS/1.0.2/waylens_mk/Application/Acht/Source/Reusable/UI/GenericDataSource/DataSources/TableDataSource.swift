//
//  CollectionDataSource.swift
//  GenericDataSource
//
//  Created by Andrea Prearo on 4/20/17.
//  Copyright © 2017 Andrea Prearo. All rights reserved.
//

import UIKit

public typealias TableItemSelectionHandlerType = (IndexPath) -> Void
public typealias CellInstantiator = (IndexPath) -> CellInstantiateType
//public typealias CellDataMapper<T> = (UITableViewCell, T) -> Void
public typealias CellConfigurator<T> = (UITableViewCell, T, IndexPath) -> Void

public enum CellInstantiateType {
    case Class(cellStyle: UITableViewCell.CellStyle)
    case CustomClass(type: UITableViewCell.Type)
    case Nib(nibName: String)
}

public enum TableSetting {
    case rowHeight((IndexPath) -> CGFloat)
    case rowEditingStyle((IndexPath) -> UITableViewCell.EditingStyle)
    case shouldHighlightRow((IndexPath) -> Bool)
    case sectionHeaderHeight((Int) -> CGFloat)
    case titleForSectionHeader((Int) -> String?)
    case viewForSectionHeader((Int) -> UIView?)
}

open class TableDataSource<Provider: CollectionDataProvider>:
    NSObject,
    UITableViewDataSource,
    UITableViewDelegate
{
    // MARK: - Delegates
    public var tableItemSelectionHandler: CollectionItemSelectionHandlerType?
    public var tableItemDeselectionHandler: CollectionItemSelectionHandlerType?
    public var tableItemSwipeDeletionHandler: CollectionItemSelectionHandlerType?

    // MARK: - Private Properties
    let provider: Provider
    let cellInstantiator: CellInstantiator
    let tableSettings: [TableSetting]

    private var cellConfigurators: [CellConfigurator<Provider.T>] = []

    init(
        provider: Provider,
        tableSettings: [TableSetting],
        cellInstantiator: @escaping CellInstantiator,
        cellConfigurator: @escaping CellConfigurator<Provider.T>
        ) {
        self.provider = provider
        self.tableSettings = tableSettings
        self.cellInstantiator = cellInstantiator
        self.cellConfigurators.append(cellConfigurator)

        super.init()
    }

    @discardableResult
    public func appendCellConfigurator(_ cellConfigurator: @escaping CellConfigurator<Provider.T>) -> Self {
        cellConfigurators.append(cellConfigurator)
        return self
    }

    // MARK: - UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return provider.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 44.0
        
        tableSettings.forEach { (setting) in
            switch setting {
            case .rowHeight(let block):
                height = block(indexPath)
                return
            default:
                break
            }
        }
        
        return height
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = tableView.sectionHeaderHeight

        tableSettings.forEach { (setting) in
            switch setting {
            case .sectionHeaderHeight(let block):
                height = block(section)
                return
            default:
                break
            }
        }

        return height
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String? = nil

        tableSettings.forEach { (setting) in
            switch setting {
            case .titleForSectionHeader(let block):
                title = block(section)
                return
            default:
                break
            }
        }

        return title
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: UIView? = nil

        tableSettings.forEach { (setting) in
            switch setting {
            case .viewForSectionHeader(let block):
                header = block(section)
                return
            default:
                break
            }
        }

        return header
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        var value = true
        
        tableSettings.forEach { (setting) in
            switch setting {
            case .shouldHighlightRow(let block):
                value = block(indexPath)
                return
            default:
                break
            }
        }
        
        return value
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instantiateType = cellInstantiator(indexPath)

        let cell: UITableViewCell = {
            switch instantiateType {
            case .Class(let cellStyle):
                let reuseIdentifier = "\(UITableViewCell.self)-\(cellStyle.rawValue)"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                    return UITableViewCell(style: cellStyle, reuseIdentifier: reuseIdentifier)
                }

                return cell
            case .CustomClass(let type):
                let reuseIdentifier = "\(type)"

                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                    tableView.register(type, forCellReuseIdentifier: reuseIdentifier)

                    return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                }

                return cell
            case .Nib(let nibName):
                let reuseIdentifier = "\(nibName)"
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                    tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
                    
                    return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                }
                
                return cell
            }

        }()

        let item = provider.item(at: indexPath)
        if let item = item {
            cellConfigurators.forEach { (configurator) in
                configurator(cell, item, indexPath)
            }
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableItemSelectionHandler?(indexPath)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableItemDeselectionHandler?(indexPath)
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        var style: UITableViewCell.EditingStyle = .none

        tableSettings.forEach { (setting) in
            switch setting {
            case .rowEditingStyle(let block):
                style = block(indexPath)
                return
            default:
                break
            }
        }

        return style
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableItemSwipeDeletionHandler?(indexPath)
        default:
            break
        }
    }
}
