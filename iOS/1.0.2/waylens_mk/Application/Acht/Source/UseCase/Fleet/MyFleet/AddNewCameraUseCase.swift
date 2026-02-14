//
//  AddNewCameraUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewCameraUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let cameraSN: String
    private let password: String

    public init(
        cameraSN: String,
        password: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.cameraSN = cameraSN
        self.password = password
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        WaylensClientS.shared.request(
            .addCamera(
                cameraSN: cameraSN,
                password: password
            )
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

protocol AddNewCameraUseCaseFactory {
    func makeAddNewCameraUseCase(cameraSN: String, password: String) -> UseCase
}
