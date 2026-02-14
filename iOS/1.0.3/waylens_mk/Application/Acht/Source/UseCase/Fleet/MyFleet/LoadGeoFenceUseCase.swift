//
//  LoadGeoFenceUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class LoadGeoFenceUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let geoFenceID: GeoFenceId

    public init(geoFenceID: GeoFenceId, actionDispatcher: ActionDispatcher) {
        self.geoFenceID = geoFenceID
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))
        actionDispatcher.dispatch(GeoFenceActions.beginLoadingGeoFence(geoFenceID))

        WaylensClientS.shared.request(
            .geoFenceDetail(fenceID: geoFenceID)
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            switch result {
            case .success(let value):
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if let geoFence = try? JSONDecoder().decode(GeoFence.self, from: value.jsonData ?? Data()) {
                        DispatchQueue.main.async {
                            self.actionDispatcher.dispatch(GeoFenceActions.loadedGeoFence(geoFence))
                        }
                    }
                }
            case .failure(_):
                self.actionDispatcher.dispatch(GeoFenceActions.failedToLoadGeoFence(self.geoFenceID))
                break
            }
        }
    }

}

protocol LoadGeoFenceUseCaseFactory {
    func makeLoadGeoFenceUseCase(geoFenceID: GeoFenceId?) -> UseCase
}
