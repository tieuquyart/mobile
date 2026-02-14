//
//  DataFilter.swift
//  Fleet
//
//  Created by forkon on 2019/12/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public protocol DataFilter {
    func match(_ dataModel: Any) -> Bool
}

protocol DataFilterGenerator {
    func dataFilter() -> DataFilter
}
