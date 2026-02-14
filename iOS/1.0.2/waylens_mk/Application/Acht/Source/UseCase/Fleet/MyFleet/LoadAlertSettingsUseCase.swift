//
//  LoadAlertSettingsUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadAlertSettingsUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
//        WaylensClientS.shared.request(
//            .userNotificationInfo
//        ) { (result) in
//            switch result {
//            case .success(let response):
//                if let alertSettings = response["notificationType"] as? [String] {
//                    self.actionDispatcher.dispatch(AlertSettingsActions.loadAlertSettings(alertSettings))
//                } else {
//                    let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: WLAPIError.jsonFormatError.message ?? "")
//                    self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//                }
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
//                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//            }
//        }
    }

}

protocol LoadAlertSettingsUseCaseFactory {
    func makeLoadAlertSettingsUseCase() -> UseCase
}
