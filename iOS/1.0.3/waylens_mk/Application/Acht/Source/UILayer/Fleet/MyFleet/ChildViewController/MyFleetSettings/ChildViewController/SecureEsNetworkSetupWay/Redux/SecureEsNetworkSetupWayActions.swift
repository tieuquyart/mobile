//
//  SecureEsNetworkSetupWayActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum SecureEsNetworkSetupWayActions: Action {
//    case xxxAlertDismissed
//    case xxxButtonTapped
//    case xxxResponse(Result)
}

struct SecureEsNetworkSetupWayFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
