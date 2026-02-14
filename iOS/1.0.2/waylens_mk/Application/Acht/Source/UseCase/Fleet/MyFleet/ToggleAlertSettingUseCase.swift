//
//  ToggleAlertSettingUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ToggleAlertSettingUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let alertSetting: AlertSettingSet
    let isOn: Bool

    public init(alertSetting: AlertSettingSet, isOn: Bool, actionDispatcher: ActionDispatcher) {
        self.alertSetting = alertSetting
        self.isOn = isOn
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(AlertSettingsActions.toggleAlertSettings(alertSetting, isOn))
    }

}

protocol ToggleAlertSettingUseCaseFactory {
    func makeToggleAlertSettingUseCase(alertSetting: AlertSettingSet, isOn: Bool) -> UseCase
}
