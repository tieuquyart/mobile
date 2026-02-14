//
//  GeoFenceListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceListDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceListViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRuleForEdit? = nil, type: GeoFenceListType = .all) {
        self.stateStore = ReSwift.Store(
            reducer: Reducers.GeoFenceListReducer,
            state: GeoFenceListViewControllerState(
                rule: rule,
                type: type
            )
        )
    }

    func makeGeoFenceListViewController() -> GeoFenceListViewController {
        let stateObservable = makeGeoFenceListViewControllerStateObservable()
        let observer = ObserverForGeoFenceList(state: stateObservable)
        let userInterface = GeoFenceListRootView()
        let viewController = GeoFenceListViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            loadGeoFenceListUseCaseFactory: self,
            loadGeoFenceUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            removeGeoFenceUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

    func makeGeoFenceListViewControllerForDraftBox() -> GeoFenceListViewController {
        let stateObservable = makeGeoFenceListViewControllerStateObservable()
        let observer = ObserverForGeoFenceList(state: stateObservable)
        let userInterface = GeoFenceListRootViewForDraftBox()
        let viewController = GeoFenceListViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            loadGeoFenceListUseCaseFactory: self,
            loadGeoFenceUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            removeGeoFenceUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceListDependencyContainer {

    func makeGeoFenceListViewControllerStateObservable() -> Observable<GeoFenceListViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceListDependencyContainer: GeoFenceListViewControllerFactory {

    func makeViewController(for selection: IndexPath) -> UIViewController? {
        if case(.loaded(let geoFences)) = stateStore.state.loadedState {
            let fence = geoFences[selection.row]
            let rule = stateStore.state.rule

            if stateStore.state.type == .all {
                if let shape = GeoFenceShapeForEdit(shape: fence.shape) {
                    let vc = GeoFenceDrawingDependencyContainer(
                        isEditable: false,
                        rule: stateStore.state.rule,
                        fenceShape: shape
                    )
                        .makeGeoFenceDrawingViewController()

                    return vc
                }
            }
            else {
                let vc = AddNewGeoFenceDependencyContainer(
                    rule: rule,
                    fence: GeoFence(item: fence)
                ).makeAddNewGeoFenceViewController().embedInNavigationController()
                vc.title = fence.name
                
                return vc
            }
        }

        return nil
    }

}

//MARK: - Use Case

extension GeoFenceListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<GeoFenceListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension GeoFenceListDependencyContainer: LoadGeoFenceListUseCaseFactory {

    func makeLoadGeoFenceListUseCase() -> UseCase {
        return LoadGeoFenceListUseCase(type: stateStore.state.type, actionDispatcher: actionDispatcher)
    }
    
}

extension GeoFenceListDependencyContainer: LoadGeoFenceUseCaseFactory {

    func makeLoadGeoFenceUseCase(geoFenceID: GeoFenceId?) -> UseCase {
        if let geoFenceID = geoFenceID, !stateStore.state.loadingGeoFences.contains(geoFenceID) {
            return LoadGeoFenceUseCase(geoFenceID: geoFenceID, actionDispatcher: actionDispatcher)
        }
        else {
            return DoNothingUseCase()
        }
    }

}

extension GeoFenceListDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceListDependencyContainer: RemoveGeoFenceUseCaseFactory {

    func makeRemoveGeoFenceUseCase(fenceID: GeoFenceId, completion: @escaping RemoveGeoFenceUseCase.Completion) -> UseCase {
        return RemoveGeoFenceUseCase(
            fenceID: fenceID,
            actionDispatcher: actionDispatcher,
            completion: completion
        )
    }

}
