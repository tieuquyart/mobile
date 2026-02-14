//
//  BillingDetailActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum BillingDetailActions: Action {
    case loadBillingData(BillingData)
}

struct BillingDetailFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
