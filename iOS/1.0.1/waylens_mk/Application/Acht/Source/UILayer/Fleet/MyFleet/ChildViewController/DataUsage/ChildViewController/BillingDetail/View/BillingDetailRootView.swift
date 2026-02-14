//
//  BillingDetailRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingDetailRootView: CardFlowRootView {
    weak var ixResponder: BillingDetailIxResponder?

    private let footerView: BillingDetailFooterView = {
        let footerView = BillingDetailFooterView.createFromNib()!
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()

    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configCardFlowView(_ cardFlowView: CardFlowView) {
        super.configCardFlowView(cardFlowView)

        cardFlowView.topMargin = 0.0
        cardFlowView.frame.size.height -= footerView.bounds.height
    }

}

//MARK: - Private

private extension BillingDetailRootView {

    func setup() {
        addSubview(footerView)

        footerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: footerView.bounds.height).isActive = true
    }

}

extension BillingDetailRootView: BillingDetailUserInterface {

    func render(newState: BillingDetailViewControllerState) {
        cardFlowView.dataSource = newState.dataSource
        cardFlowView.reloadData()

        footerView.config(withTotalDataUsageInMB: newState.dataSource.billingData?.totalDataVolumeInMB ?? 0, totalFee: newState.dataSource.billingData?.charge ?? 0)

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                HNMessage.showSuccess(message: activityIndicatingState.message)
                HNMessage.dismiss(withDelay: 1.0)
            } else {
                HNMessage.show(message: activityIndicatingState.message)
            }
        }
    }

}

