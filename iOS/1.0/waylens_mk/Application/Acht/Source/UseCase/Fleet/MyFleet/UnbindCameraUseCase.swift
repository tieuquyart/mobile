//
//  UnbindCameraUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UnbindCameraUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let vehicleID: String
    private let cameraSN: String

    public init(
        vehicleID: String,
        cameraSN: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.vehicleID = vehicleID
        self.cameraSN = cameraSN
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .unbinding))
        WaylensClientS.shared.request(.unbindVehicleCamera(vehicleID: vehicleID, cameraSN: cameraSN)) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUnbinding))
                self.actionDispatcher.dispatch(VehicleActions.updateCameraBound(cameraSN: nil))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Unbind", comment: "Failed to Unbind"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol UnbindCameraUseCaseFactory {
    func makeUnbindCameraUseCase() -> UseCase
}
