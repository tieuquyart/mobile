//
//  CleanGeoFenceUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class CleanGeoFenceUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(GeoFenceDrawingActions.cleanGeoFence)
    }

}

protocol CleanGeoFenceUseCaseFactory {
    func makeCleanGeoFenceUseCase() -> UseCase
}
