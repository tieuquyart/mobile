//
//  BindDriverUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BindDriverUseCase: UseCase {
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

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
//            let errorDescription: String = "failed"
//            let message = ErrorMessage(title: NSLocalizedString("Failed to Bind", comment: "Failed to Bind"), message: errorDescription)
//            self.actionDispatcher.dispatch(BindDriverActions.failToBind(errorMessage: message))
//        }

        WaylensClientS.shared.request(.bindVehicleDriver(vehicleID: vehicleID, driverID: driver.driverID!)) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneBinding))
                self.vehicleActionDispatcher.dispatch(VehicleActions.updateDriverBound(self.driver))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Bind", comment: "Failed to Bind"), message: errorDescription)
                self.actionDispatcher.dispatch(BindDriverActions.failToBind(errorMessage: message))
            }
        }
    }

}

protocol BindDriverUseCaseFactory {
    func makeBindDriverUseCase() -> UseCase
}
