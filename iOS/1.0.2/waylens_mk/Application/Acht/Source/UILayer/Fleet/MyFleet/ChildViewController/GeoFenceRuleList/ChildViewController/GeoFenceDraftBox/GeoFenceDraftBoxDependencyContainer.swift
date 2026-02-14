//
//  GeoFenceDraftBoxDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceDraftBoxDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceDraftBoxViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.GeoFenceDraftBoxReducer, state: GeoFenceDraftBoxViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeGeoFenceDraftBoxViewController() -> GeoFenceDraftBoxViewController {
        let stateObservable = makeGeoFenceDraftBoxViewControllerStateObservable()
        let observer = ObserverForGeoFenceDraftBox(state: stateObservable)
        let userInterface = GeoFenceDraftBoxRootView()
        let viewController = GeoFenceDraftBoxViewController(
            observer: observer,
            userInterface: userInterface,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceDraftBoxDependencyContainer {

    func makeGeoFenceDraftBoxViewControllerStateObservable() -> Observable<GeoFenceDraftBoxViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceDraftBoxDependencyContainer: GeoFenceDraftBoxViewControllerFactory {


}

//MARK: - Use Case

extension GeoFenceDraftBoxDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<GeoFenceDraftBoxFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}
