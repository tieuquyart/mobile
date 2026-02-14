//
//  BillingHistoryCardView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingHistoryCardView: CardFlowViewCard {

    public var eventHandler = CardFlowViewCardEventHandler<BillingData>()

    init(items: [BillingData]) {
        let contentView = BillingHistoryCardContentView()
        contentView.eventHandler = eventHandler
        contentView.items = items
        super.init(contentView: contentView)

        let headerView = BillingHistoryCardHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 26.0))
        self.headerView = headerView
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private final class BillingHistoryCardHeaderView: UILabel, Themed {

    override init(frame: CGRect) {
        super.init(frame: frame)

        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    func applyTheme() {
        backgroundColor = UIColor.semanticColor(.cardHeaderBackground)
        attributedText = NSAttributedString(
            string: NSLocalizedString("Billing History", comment: "Billing History"),
            font: UIFont(name: "BeVietnamPro-Regular", size: 12)!,
            textColor: UIColor.semanticColor(.label(.primary)),
            indent: CGFloat(16.0)
        )
    }

}
