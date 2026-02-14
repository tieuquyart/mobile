//
//  BarChartCardData.swift
//  Fleet
//
//  Created by forkon on 2019/10/17.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ChartData {

    struct Item {
        var date: Date
        var value: Double
    }

    private(set) var items: [ChartData.Item]

    init(items: [ChartData.Item]) {
        self.items = items
    }

}
