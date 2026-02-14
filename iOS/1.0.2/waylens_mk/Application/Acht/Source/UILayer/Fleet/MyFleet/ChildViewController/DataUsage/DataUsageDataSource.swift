//
//  DataUsageDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class DataUsageDataSource: NSObject, CardFlowViewDataSource {
    public let thisMonthBillingData: BillingData?
    public let historyBillingDataArray: [BillingData]

    public var itemSelectionHandler: ((BillingData) -> Void)?

    public init(thisMonthBillingData: BillingData?, historyBillingDataArray: [BillingData]) {
        self.thisMonthBillingData = thisMonthBillingData
        self.historyBillingDataArray = historyBillingDataArray
    }

    public func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        if historyBillingDataArray.isEmpty {
            return 1
        }
        return 2
    }

    public func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        if index == 0 {
            let cardView = ThisMonthCardView(billingData: thisMonthBillingData)
            cardView.eventHandler.selectBlock = { [weak self] selectedItem in
                self?.itemSelectionHandler?(selectedItem)
            }
            return cardView
        } else {
            let cardView = BillingHistoryCardView(items: historyBillingDataArray)
            cardView.eventHandler.selectBlock = { [weak self] selectedItem in
                self?.itemSelectionHandler?(selectedItem)
            }
            return cardView
        }
    }

}

