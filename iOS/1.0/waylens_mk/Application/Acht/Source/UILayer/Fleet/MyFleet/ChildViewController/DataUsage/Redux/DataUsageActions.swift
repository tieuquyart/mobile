//
//  DataUsageActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum DataUsageActions: Action {
    case loadBillingData(BillingData)
    case loadHistoricalBillingData([BillingData])
}

struct DataUsageFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
