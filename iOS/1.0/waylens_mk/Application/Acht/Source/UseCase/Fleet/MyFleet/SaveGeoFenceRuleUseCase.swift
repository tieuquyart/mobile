//
//  SaveGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class SaveGeoFenceRuleUseCase: UseCase {
    typealias Completion = () -> ()
    let actionDispatcher: ActionDispatcher

    private let rule: GeoFenceRuleForEdit
    private let completion: Completion?

    public init(rule: GeoFenceRuleForEdit, actionDispatcher: ActionDispatcher, completion: Completion?) {
        self.rule = rule
        self.actionDispatcher = actionDispatcher
        self.completion = completion
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        let api: FleetAPI

        var vehicleList: [VehicleId]? = rule.vehicleList

        if rule.scope == .all {
            vehicleList = nil
        }

        if let fenceRuleID = rule.fenceRuleID {
            api = .editGeoFenceRule(
                fenceRuleID: fenceRuleID,
                name: rule.name!,
                type: rule.type!.stringArrayValue,
                scope: rule.scope!.rawValue,
                vehicleList: vehicleList
            )
        }
        else {
            api = .addGeoFenceRule(
                fenceID: rule.fenceID!,
                name: rule.name!,
                type: rule.type!.stringArrayValue,
                scope: rule.scope!.rawValue,
                vehicleList: vehicleList
            )
        }

        WaylensClientS.shared.request(api) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
                self.completion?()
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol SaveGeoFenceRuleUseCaseFactory {
    func makeSaveGeoFenceRuleUseCase(completion: SaveGeoFenceRuleUseCase.Completion?) -> UseCase
}
