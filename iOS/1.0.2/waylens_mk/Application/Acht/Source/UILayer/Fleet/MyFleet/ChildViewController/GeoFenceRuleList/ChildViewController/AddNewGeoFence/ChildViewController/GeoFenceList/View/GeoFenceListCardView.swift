//
//  GeoFenceListCardView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceListCardView: CardFlowViewCard {
    public var eventHandler = CardFlowViewCardEventHandler<GeoFenceListItem>()

    init(item: GeoFenceListItem) {
        let contentView = GeoFenceListCardContentView()
        contentView.item = item
        contentView.eventHandler = eventHandler
        super.init(contentView: contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
