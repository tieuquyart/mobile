//
//  NotificationListCardView.swift
//  Fleet
//
//  Created by forkon on 2019/12/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class NotificationListCardView: CardFlowViewCard {

    public var eventHandler = CardFlowViewCardEventHandler<DriverTimelineEvent>()

    init(item: DriverTimelineEvent) {
        let contentView = NotificationListCardContentView(item: item)
        contentView.eventHandler = eventHandler
        super.init(contentView: contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
