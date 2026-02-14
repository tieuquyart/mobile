//
//  LoadGeoFenceListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class LoadGeoFenceListUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let type: GeoFenceListType

    public init(type: GeoFenceListType, actionDispatcher: ActionDispatcher) {
        self.type = type
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .geoFenceList(type: type.rawValue)
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            switch result {
            case .success(let value):
                if let fenceList = value["fenceList"] as? [[String : Any]] {
                    self.actionDispatcher.dispatch(GeoFenceListActions.loadGeoFences(fenceList.compactMap{try? JSONDecoder().decode(GeoFenceListItem.self, from: $0.jsonData ?? Data())}))
                }
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol LoadGeoFenceListUseCaseFactory {
    func makeLoadGeoFenceListUseCase() -> UseCase
}
