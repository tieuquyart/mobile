//
//  TableViewSection.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class TableViewRow {
    public var image: UIImage? = nil
    public var title: String
    public var detail: String? = nil
    public let cellType: UITableViewCell.Type
    public let cellHeight: CGFloat
    public let cellStyle: UITableViewCell.CellStyle
    public var detailViewControllerClass: UIViewController.Type?

    public init(
        image: UIImage? = nil,
        title: String,
        detail: String? = nil,
        cellType: UITableViewCell.Type = UITableViewCell.self,
        cellHeight: CGFloat = 60.0,
        cellStyle: UITableViewCell.CellStyle = .default,
        detailViewControllerClass: UIViewController.Type? = nil
        ) {
        self.image = image
        self.title = title
        self.detail = detail
        self.cellType = cellType
        self.cellHeight = cellHeight
        self.cellStyle = cellStyle
        self.detailViewControllerClass = detailViewControllerClass
    }
}

extension TableViewRow: Equatable {

    public static func == (lhs: TableViewRow, rhs: TableViewRow) -> Bool {
        return lhs.image == rhs.image &&
            lhs.title == rhs.title &&
            lhs.detail == rhs.detail &&
            lhs.cellType == rhs.cellType &&
            lhs.cellHeight == rhs.cellHeight &&
            lhs.cellStyle == rhs.cellStyle &&
            lhs.detailViewControllerClass == rhs.detailViewControllerClass
    }

}

public class TableViewSection {
    public let headerHeight: CGFloat
    public var items: [TableViewRow] = []

    public init(items: [TableViewRow], headerHeight: CGFloat = 12.0) {
        self.items = items
        self.headerHeight = headerHeight
    }

    var rows: [TableViewBaseRow] = []

    init(rows: [TableViewBaseRow], headerHeight: CGFloat = 12.0) {
        self.rows = rows
        self.headerHeight = headerHeight
    }
}

extension TableViewSection: Equatable {

    public static func == (lhs: TableViewSection, rhs: TableViewSection) -> Bool {
        return lhs.headerHeight == rhs.headerHeight &&
            lhs.items == rhs.items
    }

}

class TableViewSectionProvider {
    typealias SectionGetter = (Int) -> Int
    typealias RowGetter = (IndexPath) -> Int

    let sectionGetter: SectionGetter
    let rowGetter: RowGetter

    let sectionTemplates: [TableViewSection]

    init(sectionTemplates: () -> [TableViewSection], sectionGetter: @escaping SectionGetter, rowGetter: @escaping RowGetter) {
        self.sectionTemplates = sectionTemplates()
        self.sectionGetter = sectionGetter
        self.rowGetter = rowGetter
    }
}

class TableViewBaseRow {
    let cellType: UITableViewCell.Type
    var cellHeight: CGFloat = 44.0

    public enum CellInstantiateType {
        case Class(cellStyle: UITableViewCell.CellStyle)
        case CustomClass
        case Nib(nibName: String)
    }

    internal final var cellSetup: ((UITableViewCell) -> Void)?
    internal final var onUpdate: ((TableViewBaseRow) -> Void)?
    internal final var dynamicRowHeight: ((UITableView, IndexPath) -> CGFloat)?

    internal final let cellInstantiateType: CellInstantiateType

    internal init<T: UITableViewCell>(
        cellInstantiateType: CellInstantiateType = .Class(cellStyle: .default),
        cellSetup: ((T) -> Void)? = nil
        ) {
        self.cellType = T.self
        self.cellInstantiateType = cellInstantiateType
        self.cellSetup = { cellSetup?(($0 as! T)) }
    }

    public func configure(handler: ((TableViewBaseRow) -> Void)) -> TableViewBaseRow {
        handler(self)
        return self
    }

}

class TableViewRowCustom<T: UITableViewCell, D>: TableViewBaseRow {

    public typealias CellDataMapper = ((T, D) -> Void)

    internal final let cellDataMapper: CellDataMapper?
    internal final var onSelected: ((T, D) -> Void)?

    required public init(
        cellInstantiateType: CellInstantiateType = .Class(cellStyle: .default),
        cellSetup: ((T) -> Void)? = nil,
        cellDataMapper: CellDataMapper? = nil
        ) {
        self.cellDataMapper = cellDataMapper
        super.init(cellInstantiateType: cellInstantiateType, cellSetup: cellSetup)
    }

    @discardableResult
    public final func cellSetup(_ handler: @escaping ((T) -> Void)) -> Self {
        cellSetup = { handler(($0 as! T)) }
        return self
    }

//    @discardableResult
//    public final func cellUpdate(_ update: ((T) -> Void)) -> Self {
//        update(cell)
//        return self
//    }
}
