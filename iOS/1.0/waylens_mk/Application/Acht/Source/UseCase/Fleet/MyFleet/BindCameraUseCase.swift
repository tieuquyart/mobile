//
//  BindCameraUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BindCameraUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let vehicleActionDispatcher: ActionDispatcher

    private let vehicleID: String
    private let cameraSN: String
    
    public init(
        vehicleID: String,
        cameraSN: String,
        actionDispatcher: ActionDispatcher,
        vehicleActionDispatcher: ActionDispatcher
        ) {
        self.vehicleID = vehicleID
        self.cameraSN = cameraSN
        self.actionDispatcher = actionDispatcher
        self.vehicleActionDispatcher = vehicleActionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .binding))

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
//            let errorDescription: String = "failed"
//            let message = ErrorMessage(title: NSLocalizedString("Failed to Bind", comment: "Failed to Bind"), message: errorDescription)
//            self.actionDispatcher.dispatch(BindCameraActions.failToBind(errorMessage: message))
//        }

        WaylensClientS.shared.request(.bindVehicleCamera(vehicleID: vehicleID, cameraSN: cameraSN)) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneBinding))
                self.vehicleActionDispatcher.dispatch(VehicleActions.updateCameraBound(cameraSN: self.cameraSN))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Bind", comment: "Failed to Bind"), message: errorDescription)
                self.actionDispatcher.dispatch(BindCameraActions.failToBind(errorMessage: message))
            }
        }
    }

}

protocol BindCameraUseCaseFactory {
    func makeBindCameraUseCase() -> UseCase
}
