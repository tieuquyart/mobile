//
//  RequestPasswordResetUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class RequestPasswordResetUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(apiClient: WaylensClientS,
                actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
//        WaylensClientS.shared.requestPasswordReset(email: emailText) { [weak self] (result) in
//            if result.isSuccess {
//                self?.setupTimer()
//            } else {
//                if result.error?.asAPIError == .networkError {
//                    self?.mainButton.setEnabled(enabled: true)
//                }
//                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to re-send verification", comment: "Fail to re-send verification"))
//            }
//        }
    }

}

protocol RequestPasswordResetUseCaseFactory {
    func makeRequestPasswordResetUseCase() -> UseCase
}
