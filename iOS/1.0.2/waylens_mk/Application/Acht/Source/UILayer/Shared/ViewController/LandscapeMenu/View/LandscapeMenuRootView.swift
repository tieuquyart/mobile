//
//  LandscapeMenuRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

private let defaultRowHeight: CGFloat = 56.0

class LandscapeMenuRootView: UIView {
    weak var ixResponder: LandscapeMenuIxResponder?

    private var dataSource: LandscapeMenuDataSource? = nil

    private var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        return tableView
    }()

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var tableViewHeight: CGFloat = CGFloat((tableView.dataSource as? LandscapeMenuDataSource)?.provider.items.first?.count ?? 0) * defaultRowHeight
        let maxTableViewHeight = layoutMarginsGuide.layoutFrame.height - layoutMargins.bottom - layoutMargins.top

        if tableViewHeight > maxTableViewHeight {
            tableViewHeight = maxTableViewHeight
            tableView.isScrollEnabled = true
        }
        else {
            tableView.isScrollEnabled = false
        }

        var tableViewFrame = RectDivider(rect: layoutMarginsGuide.layoutFrame).divide(atPercent: 0.25, from: .maxXEdge)
        tableViewFrame.size.height = tableViewHeight
        tableView.frame = tableViewFrame
        tableView.center = CGPoint(x: tableView.center.x, y: bounds.height / 2)

        fadedLeftRightEdges(leftEdgeInset: tableView.frame.origin.x, rightEdgeInset: 0.0)
    }
}

//MARK: - Private

private extension LandscapeMenuRootView {

    func setup() {
        addSubview(tableView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    @objc
    func didTap() {
        ixResponder?.dismiss()
    }

}

extension LandscapeMenuRootView: LandscapeMenuUserInterface {

    func render(newState: [LandscapeMenuItem]) {
        dataSource = LandscapeMenuDataSource(items: newState)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        setNeedsLayout()
    }

}

extension LandscapeMenuRootView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: tableView) == true {
            return false
        }
        return true
    }

}

private class LandscapeMenuDataSource: TableArrayDataSource<LandscapeMenuItem> {

    public convenience init(items: [LandscapeMenuItem]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return defaultRowHeight}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .default)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.highlightedTextColor = UIColor.black

            cell.textLabel?.text = item.title
        }
    }

}
