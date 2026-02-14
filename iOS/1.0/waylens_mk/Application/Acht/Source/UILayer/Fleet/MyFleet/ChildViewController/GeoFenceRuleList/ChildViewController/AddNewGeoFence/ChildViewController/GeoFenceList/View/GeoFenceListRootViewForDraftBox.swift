//
//  GeoFenceListRootViewForDraftBox.swift
//  Fleet
//
//  Created by forkon on 2020/6/3.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import DifferenceKit

class GeoFenceListRootViewForDraftBox: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: GeoFenceListIxResponder?

    private var dataSource: GeoFenceListForDraftBoxDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension GeoFenceListRootViewForDraftBox {

    func setup() {
        setupStatefulView()
        startLoading()
    }

}

extension GeoFenceListRootViewForDraftBox: GeoFenceListUserInterface {

    func render(newState: GeoFenceListViewControllerState) {
        switch newState.loadedState {
        case .notLoaded:
            break
        case .loaded(let geoFenceListItems):
            let geoFences = geoFenceListItems.map{GeoFence(item: $0)}

            let needsReloadAll = (dataSource == nil)

            var changeset: StagedChangeset<[GeoFence]>? = nil

            if !needsReloadAll {
                if let source = dataSource?.provider.items.first {
                    changeset = StagedChangeset(source: source, target: geoFences)
                }
            }

            dataSource = GeoFenceListForDraftBoxDataSource(items: geoFences, requestShapeDetailHandler: {[weak self] fenceId in
                self?.ixResponder?.requestGeoFenceShapeDetail(with: fenceId)
            })
            dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
                self?.ixResponder?.select(indexPath: indexPath)
            }
            dataSource?.tableItemSwipeDeletionHandler = { [weak self] indexPath in
                let item = geoFences[indexPath.row]
                self?.ixResponder?.delete(item: item)
            }

            tableView.dataSource = dataSource
            tableView.delegate = dataSource

            if needsReloadAll {
                tableView.reloadData()
            }
            else {
                if let changeset = changeset {
                    tableView.reload(using: changeset, with: UITableView.RowAnimation.automatic) { (data) in

                    }
                }
            }

            endLoading()

            let activityIndicatingState = newState.viewState.activityIndicatingState
            if activityIndicatingState == .removing {
                HNMessage.show(message: activityIndicatingState.message)
            } else {
                HNMessage.dismiss()
            }
        }
    }

}

public class GeoFenceListForDraftBoxDataSource: TableArrayDataSource<GeoFence> {
    public typealias RequestShapeDetailHandler = (String) -> ()

    private var requestShapeDetailHandler: RequestShapeDetailHandler?

    public convenience init(items: [GeoFence], requestShapeDetailHandler: RequestShapeDetailHandler?) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.rowEditingStyle({_ in return .delete}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .default)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configValue1StyleCell(cell)

            cell.imageView?.image = #imageLiteral(resourceName: "Draft box")
            cell.textLabel?.text = item.name

            if item.shape == .unknown {
                let indicator = UIActivityIndicatorView(style: .gray)
                indicator.startAnimating()
                cell.accessoryView = indicator

                requestShapeDetailHandler?(item.fenceID)
            }
            else {
                (cell.accessoryView as? UIActivityIndicatorView)?.stopAnimating()
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            }
        }

        self.requestShapeDetailHandler = requestShapeDetailHandler
    }

}
