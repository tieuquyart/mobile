//
//  SaveGeoFenceUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class SaveGeoFenceUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let name: String
    private let shape: GeoFenceShapeForEdit

    public init(name: String, shape: GeoFenceShapeForEdit, actionDispatcher: ActionDispatcher) {
        self.name = name
        self.shape = shape
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))

        var center: CLLocationCoordinate2D?
        var radius: Int?
        var polygon: [CLLocationCoordinate2D]?

        switch shape {
        case .circle(let c, let r):
            center = c
            radius = Int(r ?? 0)
        case .polygon(let p):
            polygon = p
        }

        WaylensClientS.shared.request(
            .addGeoFence(name: name, center: center, radius: radius, polygon: polygon)
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            switch result {
            case .success(let value):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
                if let fenceId = value["fenceID"] as? String {
                    self.actionDispatcher.dispatch(GeoFenceDrawingActions.savedGeoFence(geoFenceId: fenceId))
                }
                break
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol SaveGeoFenceUseCaseFactory {
    func makeSaveGeoFenceUseCase() -> UseCase
}
