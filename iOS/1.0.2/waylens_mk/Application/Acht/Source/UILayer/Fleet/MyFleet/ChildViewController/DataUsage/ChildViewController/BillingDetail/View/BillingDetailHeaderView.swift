//
//  BillingDetailHeaderView.swift
//  Fleet
//
//  Created by forkon on 2019/11/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BillingDetailHeaderView: UIView {
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var cameraCountLabel: UILabel!

    func config(with dateRange: DateRange, cameraCount: Int) {
        dateRangeLabel.text = dateRange.description

        let format: String = NSLocalizedString("camera count", comment: "camera count")
        cameraCountLabel.text = String.localizedStringWithFormat(format, cameraCount)
    }
}

extension BillingDetailHeaderView: NibCreatable {}
