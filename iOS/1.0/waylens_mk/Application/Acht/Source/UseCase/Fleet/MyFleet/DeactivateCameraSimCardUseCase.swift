//
//  DeactivateCameraSimCardUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DeactivateCameraSimCardUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

//        WaylensClientS.shared.request(
//
//        ) { (result) in
//            switch result {
//            case .success(_):
//                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
//                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//            }
//        }
    }

}

protocol DeactivateCameraSimCardUseCaseFactory {
    func makeDeactivateCameraSimCardUseCase() -> UseCase
}
