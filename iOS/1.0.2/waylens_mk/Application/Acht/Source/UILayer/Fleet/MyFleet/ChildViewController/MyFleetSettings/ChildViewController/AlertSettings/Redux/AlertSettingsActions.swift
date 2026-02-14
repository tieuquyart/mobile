//
//  AlertSettingsActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum AlertSettingsActions: Action {
    case loadAlertSettings([String])
    case toggleAlertSettings(AlertSettingSet, Bool)
}

struct AlertSettingsFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
