//
//  ComposeGeoFenceUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class ComposeGeoFenceUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let composedData: Any

    public init(composedData: Any, actionDispatcher: ActionDispatcher) {
        self.composedData = composedData
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(GeoFenceDrawingActions.composeGeoFence(composedData: composedData))
    }

}

protocol ComposeGeoFenceUseCaseFactory {
    func makeComposeGeoFenceUseCase(composedData: Any) -> UseCase
}
