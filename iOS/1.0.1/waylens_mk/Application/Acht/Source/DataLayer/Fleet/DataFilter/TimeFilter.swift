//
//  TimeFilter.swift
//  Fleet
//
//  Created by forkon on 2019/12/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class TimeFilter: DataFilter {
    private let selectedDates: [Date]

    init(selectedDates: [Date]) {
        self.selectedDates = selectedDates
    }

    func match(_ dataModel: Any) -> Bool {
        var match = false

        let mirror = Mirror(reflecting: dataModel)

        if selectedDates.isEmpty {
            match = true
        } else {
            if let date = mirror.children.first(where: {$0.label == "date"})?.value as? Date, selectedDates.first(where: {$0.dateManager.fleetDate.compare(.isSameDay(date))}) != nil {
                match = true
            }
        }

        return match
    }
}
