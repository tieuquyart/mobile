//
//  ChangeFleetOwnerUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ChangeFleetOwnerUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let targetOwnerEmail: String
    private let currentOwnerPassword: String

    public init(
        targetOwnerEmail: String,
        currentOwnerPassword: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.targetOwnerEmail = targetOwnerEmail
        self.currentOwnerPassword = currentOwnerPassword
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .setting))

        WaylensClientS.shared.request(
            .changeFleetOwner(
                targetOwnerEmail: targetOwnerEmail,
                currentOwnerPassword: currentOwnerPassword
            )
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(MemberActions.transferFleet)
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSetting))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Set", comment: "Failed to Set"), message: errorDescription)
                self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol ChangeFleetOwnerUseCaseFactory {
    func makeChangeFleetOwnerUseCase(password: String) -> UseCase
}
