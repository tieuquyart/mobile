//
//  RemoveVehicleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class RemoveVehicleUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let vehicleID: String

    public init(
        vehicleID: String,
        actionDispatcher: ActionDispatcher
        ) {
        self.vehicleID = vehicleID
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .removing))
        WaylensClientS.shared.request(.removeVehicle(vehicleID: vehicleID)) { (result) in
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

protocol RemoveVehicleUseCaseFactory {
    func makeRemoveVehicleUseCase() -> UseCase
}
