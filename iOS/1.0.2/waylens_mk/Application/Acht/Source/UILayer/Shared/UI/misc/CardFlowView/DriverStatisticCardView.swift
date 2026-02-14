//
//  DriverStatisticCardView.swift
//  Fleet
//
//  Created by forkon on 2019/10/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

//public typealias DriverStatisticCardItem = DashboardStatisticChartModel.Item

public class DriverStatisticCardView: CardFlowViewCard {

    public var eventHandler = CardFlowViewCardEventHandler<Driver>()

    public init(items: [Driver]) {
        let contentView = DriverStatisticCardContentView()
        contentView.eventHandler = eventHandler
        contentView.items = items
        super.init(contentView: contentView)

        let headerView = TimelineCardHeaderView.createFromNib()!
        headerView.date = items.first?.summaryTime
        self.headerView = headerView
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
