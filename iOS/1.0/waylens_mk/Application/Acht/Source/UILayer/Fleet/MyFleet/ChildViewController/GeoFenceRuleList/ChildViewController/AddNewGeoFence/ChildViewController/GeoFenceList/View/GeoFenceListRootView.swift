//
//  GeoFenceListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import DifferenceKit

class GeoFenceListRootView: CardFlowRootView, WLStatefulView {
    weak var ixResponder: GeoFenceListIxResponder?

    private var items: [GeoFenceListItem] = []

    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configCardFlowView(_ cardFlowView: CardFlowView) {
        super.configCardFlowView(cardFlowView)

        cardFlowView.topMargin = 0.0
    }

}

//MARK: - Private

private extension GeoFenceListRootView {

    func setup() {
        setupStatefulView()
        startLoading()
    }

}

extension GeoFenceListRootView: GeoFenceListUserInterface {

    func render(newState: GeoFenceListViewControllerState) {
        switch newState.loadedState {
        case .notLoaded:
            break
        case .loaded(let geoFenceListItems):
            let needsReloadAll = (cardFlowView.dataSource == nil)

            var changeset: StagedChangeset<[GeoFenceListItem]>? = nil

            if !needsReloadAll {
                changeset = StagedChangeset(source: items, target: geoFenceListItems)
            }

            items = geoFenceListItems

            let header: UIView

            if newState.type == .all { // library scene
                header = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: cardFlowView.frame.width, height: 64.0))
                (header as! UILabel).attributedText = NSAttributedString(
                    string: NSLocalizedString("Select one existing graph to create a new zone:", comment: "Select one existing graph to create a new zone:"),
                    font: UIFont.systemFont(ofSize: 14.0),
                    textColor: UIColor.semanticColor(.label(.primary)),
                    indent: 20.0
                )
            }
            else { // draft box scene
                header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: cardFlowView.frame.width, height: 20.0))
            }

            cardFlowView.cardsContainer.tableHeaderView = header
            cardFlowView.dataSource = self

            if needsReloadAll {
                cardFlowView.reloadData()
            }
            else {
                if let changeset = changeset {
                    cardFlowView.cardsContainer.reload(using: changeset, with: UITableView.RowAnimation.automatic) { (data) in

                    }
                }
            }

            endLoading()
        }
    }

}

extension GeoFenceListRootView: CardFlowViewDataSource {

    public func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return items.count
    }

    public func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        let item = items[index]

        if item.shape == .unknown {
            ixResponder?.requestGeoFenceShapeDetail(with: item.fenceID)
        }

        let cardView = GeoFenceListCardView(item: item)

        cardView.eventHandler.selectBlock = { [weak self] selectedItem in
            if selectedItem.shape != .unknown {
                if let i = self?.items.firstIndex(where: {$0.fenceID == selectedItem.fenceID}) {
                    self?.ixResponder?.select(indexPath: IndexPath(row: i, section: 0))
                }
            }
        }

        return cardView
    }

}
