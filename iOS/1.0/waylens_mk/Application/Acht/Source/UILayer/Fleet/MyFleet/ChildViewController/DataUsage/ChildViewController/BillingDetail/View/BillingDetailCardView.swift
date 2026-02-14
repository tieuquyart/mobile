//
//  BillingDetailCardView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingDetailCardView: CardFlowViewCard {

    init(items: [BillingDataItem]) {
        let contentView = BillingDetailCardContentView()
        contentView.items = items
        super.init(contentView: contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
