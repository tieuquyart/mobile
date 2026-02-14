//
//  BillingDetailFooterView.swift
//  Fleet
//
//  Created by forkon on 2019/11/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingDetailFooterView: UIView {
    @IBOutlet private weak var totalUsageLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    
    func config(withTotalDataUsageInMB totalDataUsageInMB: Double, totalFee: Double) {
        totalUsageLabel.text = String(format: "%.2f GB", totalDataUsageInMB / 1024.0)
        feeLabel.text = "$" + "\(totalFee)"
    }
}

extension BillingDetailFooterView: NibCreatable {}
