//
//  SecureEsNetworkMiFiActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum SecureEsNetworkMiFiActions: Action {
//    case xxxAlertDismissed
//    case xxxButtonTapped
//    case xxxResponse(Result)
}

struct SecureEsNetworkMiFiFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
