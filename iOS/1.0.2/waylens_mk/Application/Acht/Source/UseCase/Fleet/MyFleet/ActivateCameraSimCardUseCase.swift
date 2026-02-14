//
//  ActivateCameraSimCardUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ActivateCameraSimCardUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let cameraSN: String

    public init(
        cameraSN: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.cameraSN = cameraSN
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .activating))

        WaylensClientS.shared.request(
            .activateCameraSimCard(cameraSN: cameraSN)
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneActivating))
                self.actionDispatcher.dispatch(CameraActions.activateCamera)
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Activate", comment: "Failed to Activate"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol ActivateCameraSimCardUseCaseFactory {
    func makeActivateCameraSimCardUseCase() -> UseCase
}
