//
//  UpdateObdWorkModeConfigUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

class UpdateObdWorkModeConfigUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    let camera: WLCameraDevice?
    let config: WLObdWorkModeConfig

    public init(
        camera: WLCameraDevice?,
        config: WLObdWorkModeConfig,
        actionDispatcher: ActionDispatcher
    ) {
        self.camera = camera
        self.config = config
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        guard let camera = camera else {
            return
        }

        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        var settings: [String : Any] = [
            "mode" : config.mode.toParameterValue(),
        ]

        if let voltageOn = config.voltageOn?.value, let voltageOff = config.voltageOff?.value, let voltageCheck = config.voltageCheck?.value {
            settings["voltage"] = [
                "on" : Int(voltageOn),
                "off" : Int(voltageOff),
                "check" : Int(voltageCheck),
            ]
        }

        WaylensClientS.shared.updateSettings(
            camera.sn!,
            settings: ["obdII" : settings]
            ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ObdWorkModeActions.doneSaving(config: self.config))
                self.camera?.doSetObdWorkModeConfig(self.config)
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }

    }

}

protocol UpdateObdWorkModeConfigUseCaseFactory {
    func makeUpdateObdWorkModeConfigUseCase(mode: WLObdWorkMode) -> UseCase
    func makeUpdateObdWorkModeConfigUseCase(voltageOff: Int) -> UseCase
    func makeUpdateObdWorkModeConfigUseCase(voltageOn: Int) -> UseCase
    func makeUpdateObdWorkModeConfigUseCase(voltageCheck: Int) -> UseCase
}
