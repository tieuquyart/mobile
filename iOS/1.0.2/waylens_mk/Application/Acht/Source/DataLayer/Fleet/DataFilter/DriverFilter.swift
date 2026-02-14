//
//  DriverFilter.swift
//  Fleet
//
//  Created by forkon on 2019/12/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DriverFilter: DataFilter {
    private var namesToMatch: [String] = []

    init(namesToMatch: [String]) {
        self.namesToMatch = namesToMatch
    }

    func match(_ dataModel: Any) -> Bool {
        var match = false

        let mirror = Mirror(reflecting: dataModel)

        if namesToMatch.isEmpty {
            match = true
        } else {
            if let name = mirror.children.first(where: {$0.label == "driverName"})?.value as? String, namesToMatch.contains(name) {
                match = true
            }
        }

        return match
    }
}
