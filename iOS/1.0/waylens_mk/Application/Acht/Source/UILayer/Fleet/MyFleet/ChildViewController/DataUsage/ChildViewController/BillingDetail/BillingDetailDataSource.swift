//
//  BillingDetailDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public class BillingDetailDataSource: NSObject, CardFlowViewDataSource {
    public let billingData: BillingData?

    public init(billingData: BillingData?) {
        self.billingData = billingData
    }

    public func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return billingData != nil ? 1 : 0
    }

    public func headerViewForCard(at index: Int, in cardFlowView: CardFlowView) -> UIView? {
        let header = BillingDetailHeaderView.createFromNib()
        header?.config(with: DateRange(from: billingData?.cycleStartDate ?? Date(), to: billingData?.cycleEndDate ?? Date()), cameraCount: billingData?.items.count ?? 0)
        return header
    }

    public func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        return BillingDetailCardView(items: billingData?.items ?? [])
    }

}

