//
//  LocationPickerDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class LocationPickerDependencyContainer {

    let stateStore: ReSwift.Store<LocationPickerViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.LocationPickerReducer, state: LocationPickerViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    private var consumerActionDispatcher: ActionDispatcher
    private lazy var locationRepository = FleetLocationRepository()

    init(consumerActionDispatcher: ActionDispatcher) {
        self.consumerActionDispatcher = consumerActionDispatcher
    }

    func makeLocationPickerViewController() -> LocationPickerViewController {
        let viewController = makeLocationPickerContentViewController()
        return LocationPickerViewController(contentViewController: viewController)
    }

}

//MARK: - Private

private extension LocationPickerDependencyContainer {

    func makeLocationPickerContentViewController() -> LocationPickerContentViewController {
        let stateObservable = makeLocationPickerViewControllerStateObservable()
        let observer = ObserverForLocationPicker(state: stateObservable)
        let userInterface = LocationPickerContentRootView()
        let viewController = LocationPickerContentViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            searchLocationUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

    func makeLocationPickerViewControllerStateObservable() -> Observable<LocationPickerViewControllerState> {
        return stateStore.makeObservable()
    }

    func makeLocationRepository() -> LocationRepository {
      return FleetLocationRepository()
    }

}

//MARK: - View Controller Factory

extension LocationPickerDependencyContainer: LocationPickerContentViewControllerFactory {


}

//MARK: - Use Case

extension LocationPickerDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<LocationPickerFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension LocationPickerDependencyContainer: SearchLocationUseCaseFactory {

    func makeSearchLocationUseCase(query: String) -> UseCase {
        return SearchLocationUseCase(
            query: query,
            actionDispatcher: actionDispatcher,
            locationRepository: locationRepository
//            locationRepository: makeLocationRepository()
        )
    }

}

extension LocationPickerDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        let location = stateStore.state.searchResults[indexPath.row]
        return SelectLocationUseCase(location: location, actionDispatcher: consumerActionDispatcher)
    }

}
