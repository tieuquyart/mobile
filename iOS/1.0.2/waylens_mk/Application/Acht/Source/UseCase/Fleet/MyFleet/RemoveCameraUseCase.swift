//
//  RemoveCameraUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class RemoveCameraUseCase: UseCase {
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
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .removing))
        WaylensClientS.shared.request(
            .removeCamera(cameraSN: cameraSN)
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneRemoving))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Remove", comment: "Failed to Remove"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol RemoveCameraUseCaseFactory {
    func makeRemoveCameraUseCase() -> UseCase
}
