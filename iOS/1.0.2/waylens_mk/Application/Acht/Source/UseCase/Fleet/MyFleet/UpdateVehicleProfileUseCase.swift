//
//  UpdateVehicleProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class UpdateVehicleProfileUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let profile: VehicleProfile
    private let composingProfileInfoUseCase: ComposingProfileInfoUseCase?

    public init(
        profile: VehicleProfile,
        actionDispatcher: ActionDispatcher,
        composingProfileInfoUseCase: ComposingProfileInfoUseCase? = nil
        ) {
        self.actionDispatcher = actionDispatcher
        self.profile = profile
        self.composingProfileInfoUseCase = composingProfileInfoUseCase
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        WaylensClientS.shared.request(
            .editVehicleProfile(
                vehicleID: profile.vehicleID!,
                plateNumber: profile.plateNo,
                model: profile.type
            )
        ) { (result) in
            switch result {
            case .success(_):
                self.composingProfileInfoUseCase?.start()
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol UpdateVehicleProfileUseCaseFactory {
    func makeUpdateVehicleProfileUseCase() -> UseCase
}
