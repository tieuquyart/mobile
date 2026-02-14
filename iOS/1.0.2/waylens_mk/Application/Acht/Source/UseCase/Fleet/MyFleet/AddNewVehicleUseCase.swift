//
//  AddNewVehicleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewVehicleUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let plateNumber: String?
    private let model: String?

    public init(
        plateNumber: String?,
        model: String?,
        actionDispatcher: ActionDispatcher
        ) {
        self.plateNumber = plateNumber
        self.model = model
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        guard let plateNumber = plateNumber, !plateNumber.isEmpty else {
            let errorDescription: String = NSLocalizedString("Plate number is required!", comment: "Plate number is required!")
            let message = ErrorMessage(title: NSLocalizedString("Failed to Add", comment: "Failed to Add"), message: errorDescription)
            self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))

            return
        }

        actionDispatcher.dispatch(ActivityIndicatingAction(state: .adding))

        WaylensClientS.shared.request(
            .addVehicle(
                plateNumber: plateNumber,
                model: model ?? ""
            )
        ) { (result) in
            switch result {
            case .success(let response):
                if let vehicleID = response["vehicleID"] as? String {
                    self.actionDispatcher.dispatch(AddNewVehicleActions.completeAdding(newVehicleID: vehicleID, plateNumber: plateNumber, model: self.model))
                }
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneAdding))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Add", comment: "Failed to Add"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol AddNewVehicleUseCaseFactory {
    func makeAddNewVehicleUseCase() -> UseCase
}
