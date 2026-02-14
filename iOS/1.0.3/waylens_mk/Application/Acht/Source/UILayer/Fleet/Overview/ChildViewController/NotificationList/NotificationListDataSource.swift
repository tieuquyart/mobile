//
//  NotificationListDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class NotificationListDataSource: NSObject, CardFlowViewDataSource {
    private var itemsFiltered: [DriverTimelineEvent]

    let items: [DriverTimelineEvent]

    var selectHandler: ((DriverTimelineEvent) -> ())? = nil
    let dataFilter: DataFilter?

    var drivers: [String] {
        return Array(Set(items.compactMap{$0.driverName})).sorted{$0.localizedStandardCompare($1) == .orderedAscending}
    }

    init(items: [DriverTimelineEvent], dataFilter: DataFilter?) {
        self.items = items
        self.dataFilter = dataFilter

        if let dataFilter = dataFilter {
            self.itemsFiltered = items.filter{dataFilter.match($0)}
        } else {
            self.itemsFiltered = items
        }
    }

    public func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return itemsFiltered.count
    }

    public func headerViewForCard(at index: Int, in cardFlowView: CardFlowView) -> UIView? {
        let item = itemsFiltered[index]

        let header = UILabel()
        header.attributedText = NSAttributedString(string: item.receiveTime?.toStringUsingInMessageCell() ?? "", font: UIFont(name: "BeVietnamPro-Regular", size: 14)!, textColor: UIColor.semanticColor(.label(.primary)), indent: 20.0)
        header.frame.size.height = 22.0
        return header
    }

    public func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        let item = itemsFiltered[index]

        let card = NotificationListCardView(item: item)
        card.eventHandler.selectBlock = { [weak self] timelineEvent in
            guard let strongSelf = self else {
                return
            }

            if let _ = timelineEvent.content as? DriverTimelineCameraEventContent {
                strongSelf.selectHandler?(item)
            }
        }

        return card
    }

}

