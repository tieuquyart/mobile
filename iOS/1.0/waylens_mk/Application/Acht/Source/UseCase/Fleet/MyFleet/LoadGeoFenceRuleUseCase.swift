//
//  LoadGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class LoadGeoFenceRuleUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let geoFenceRuleID: String

    public init(geoFenceRuleID: String, actionDispatcher: ActionDispatcher) {
        self.geoFenceRuleID = geoFenceRuleID
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .geoFenceRuleDetail(fenceRuleID: geoFenceRuleID)
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            switch result {
            case .success(let value):
                if let geoFenceRule = try? JSONDecoder().decode(GeoFenceRule.self, from: value.jsonData ?? Data()) {
                    self.actionDispatcher.dispatch(GeoFenceRuleDetailActions.loadGeoFenceRule(geoFenceRule))
                }
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol LoadGeoFenceRuleUseCaseFactory {
    func makeLoadGeoFenceRuleUseCase() -> UseCase
}
