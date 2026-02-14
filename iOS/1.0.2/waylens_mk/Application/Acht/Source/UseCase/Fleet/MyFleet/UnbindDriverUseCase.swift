//
//  UnbindDriverUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UnbindDriverUseCase: UseCase {
    private let actionDispatcher: ActionDispatcher
    private let vehicleActionDispatcher: ActionDispatcher
    private let vehicleID: String
    private let driver: FleetMember

    public init(
        vehicleID: String,
        driver: FleetMember,
        actionDispatcher: ActionDispatcher,
        vehicleActionDispatcher: ActionDispatcher
        ) {
        self.vehicleID = vehicleID
        self.driver = driver
        self.actionDispatcher = actionDispatcher
        self.vehicleActionDispatcher = vehicleActionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .unbinding))
        WaylensClientS.shared.request(.unbindVehicleDriver(vehicleID: vehicleID, driverID: driver.driverID!)) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUnbinding))
                self.vehicleActionDispatcher.dispatch(VehicleActions.updateDriverBound(nil))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Unbind", comment: "Failed to Unbind"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }

    }

}

protocol UnbindDriverUseCaseFactory {
    func makeUnbindDriverUseCase() -> UseCase
}
