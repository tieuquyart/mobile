//
//  CardFlowViewTimelineCard.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class TimelineCardView: CardFlowViewCard {

    public var eventHandler = CardFlowViewCardEventHandler<TimelineCardItem>()

    public init(model: TimelineCardModel) {
        let contentView = TimelineCardContentView.createFromNib()!
        contentView.items = model.itemsFiltered
        contentView.eventHandler = eventHandler
        super.init(contentView: contentView)

        self.headerView = TimelineCardHeaderView.createFromNib()!
        (self.headerView as! TimelineCardHeaderView).date = model.date.toString()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func reload() {
        if let contentView = contentView as? TimelineCardContentView {
            contentView.subviews.forEach { (subview) in
                if subview is UIStackView {
                    subview.frame.size.width = UIScreen.main.bounds.width * 0.6
                }
            }
            contentView.updateUI()
        }
        super.reload()
    }

}
