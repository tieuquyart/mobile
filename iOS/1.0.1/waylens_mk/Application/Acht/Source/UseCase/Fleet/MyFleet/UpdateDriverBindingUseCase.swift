//
//  UpdateDriverBindingUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UpdateDriverBindingUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    let vehicleActionDispatcher: ActionDispatcher
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
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .binding))
        WaylensClientS.shared.request(.updateVehicleDriverBinding(vehicleID: vehicleID, driverID: driver.driverID!)) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneBinding))
                self.vehicleActionDispatcher.dispatch(VehicleActions.updateDriverBound(self.driver))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Bind", comment: "Failed to Bind"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol UpdateDriverBindingUseCaseFactory {
    func makeUpdateDriverBindingUseCase() -> UseCase
}
