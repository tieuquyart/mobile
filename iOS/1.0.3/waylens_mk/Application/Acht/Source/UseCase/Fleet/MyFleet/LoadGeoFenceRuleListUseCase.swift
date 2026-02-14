//
//  LoadGeoFenceRuleListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class LoadGeoFenceRuleListUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .geoFenceRuleList
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(let value):
                if let fenceRuleList = value["FenceRuleList"] as? [[String : Any]] {
                    self.actionDispatcher.dispatch(GeoFenceRuleListActions.loadGeoFenceRuleList(fenceRuleList.compactMap{try? JSONDecoder().decode(GeoFenceRule.self, from: $0.jsonData ?? Data())}))
                }
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol LoadGeoFenceRuleListUseCaseFactory {
    func makeLoadGeoFenceRuleListUseCase() -> UseCase
}
