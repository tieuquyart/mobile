//
//  AdasConfigActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum AdasConfigActions: Action {
//    case xxxAlertDismissed
//    case xxxButtonTapped
//    case xxxResponse(Result)
}

struct AdasConfigFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
