//
//  DriverSummaryCardView.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public typealias DriverSummaryCardItem = Driver

public class DriverSummaryCardView: CardFlowViewCard {
    public var eventHandler = CardFlowViewCardEventHandler<DriverSummaryCardItem>()

    public init(
        items: [DriverSummaryCardItem],
        selectedSorter: DriverSorter,
        selectedSorterChangeHandler: @escaping (DriverSorter) -> ()
    ) {
        let contentView = DriverSummaryCardContentView()
        contentView.eventHandler = eventHandler
        contentView.items = items
        super.init(contentView: contentView)

        headerView = {
            var config = ItemPickerViewConfig()
            config.itemBackgroundColor = { UIColor.semanticColor(.mapFloatingPanelBackground) }

            let sortBar = ItemPickerView<DriverSorter>(
                frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 46.0),
                layout: SortBarLayout(margins: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)),
                config: config,
                items: [.name, .mileageDriven, .timeDriven, .event],
                selectedItem: selectedSorter,
                selectedItemChangeHandler: selectedSorterChangeHandler
            )
            sortBar.titleLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 12)!
            sortBar.titleLabel.text = NSLocalizedString("Sort by", comment: "Sort by")
            sortBar.autoresizingMask = [.flexibleWidth]
            return sortBar
        }()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func applyTheme() {
        super.applyTheme()

        headerView?.backgroundColor = UIColor.semanticColor(.cardHeaderBackground)
    }

}
