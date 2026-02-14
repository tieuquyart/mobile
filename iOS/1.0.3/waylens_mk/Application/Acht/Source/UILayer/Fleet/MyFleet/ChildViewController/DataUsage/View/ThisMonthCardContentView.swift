//
//  ThisMonthCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ThisMonthCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<BillingData>> {
    @IBOutlet weak var usageLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!

    var billingData: BillingData? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }
}

//MARK: - Private

private extension ThisMonthCardContentView {

    @objc func handleTap() {
        if let billingData = billingData {
            eventHandler?.selectBlock?(billingData)
        }
    }

    func updateUI() {
        usageLabel.text = String(format: "%.2f GB", (billingData?.totalDataVolumeInMB ?? 0) / 1024.0)
        feeLabel.text = "$" + "\(billingData?.charge ?? 0)"
    }
}

extension ThisMonthCardContentView: NibCreatable {}
