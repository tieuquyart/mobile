//
//  SaveAlertSettingsUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SaveAlertSettingsUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let alertSettings: AlertSettingSet

    public init(alertSettings: AlertSettingSet, actionDispatcher: ActionDispatcher) {
        self.alertSettings = alertSettings
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        WaylensClientS.shared.request(
            .unsubscribeNotification(notificationType: Array(alertSettings))
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol SaveAlertSettingsUseCaseFactory {
    func makeSaveAlertSettingsUseCase() -> UseCase
}
