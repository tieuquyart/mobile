//
//  NotificationListIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol NotificationListIxResponder: class {
    func select(indexPath: IndexPath)
    func showDetail(of event: DriverTimelineEvent)
    func applyDataFilter(_ dataFilter: DataFilter)
}
