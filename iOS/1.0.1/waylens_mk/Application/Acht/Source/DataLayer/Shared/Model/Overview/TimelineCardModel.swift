//
//  TimelineCardMode.swift
//  Fleet
//
//  Created by forkon on 2019/10/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class TimelineCardModel {
    public private(set) var date: Date
    public private(set) var itemsFiltered: [TimelineCardItem] = []
    public var dataFilter: DataFilter? = nil {
        didSet {
            filterData()
        }
    }

    private var items: [TimelineCardItem] {
        didSet {
            filterData()
        }
    }

    public init(date: Date, items: [TimelineCardItem]) {
        self.date = date
        self.items = items
    }
}

//MARK: - Private

private extension TimelineCardModel {

    func filterData() {
        if let dataFilter = dataFilter {
            itemsFiltered = items.filter{dataFilter.match($0)}
        } else {
            itemsFiltered = items
        }
    }

}
