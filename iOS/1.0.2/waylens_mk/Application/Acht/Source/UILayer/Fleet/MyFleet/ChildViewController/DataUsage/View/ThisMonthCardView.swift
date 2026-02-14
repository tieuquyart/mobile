//
//  ThisMonthCardView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ThisMonthCardView: CardFlowViewCard {
    public var eventHandler = CardFlowViewCardEventHandler<BillingData>()

    init(billingData: BillingData?) {
        let contentView = ThisMonthCardContentView.createFromNib()!
        contentView.billingData = billingData
        contentView.eventHandler = eventHandler
        super.init(contentView: contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
