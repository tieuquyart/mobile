//
//  GeoFenceDrawingDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class GeoFenceDrawingDependencyContainer {

    let stateStore: ReSwift.Store<GeoFenceDrawingViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(isEditable: Bool, rule: GeoFenceRuleForEdit, fenceShape: GeoFenceShapeForEdit) {
        self.stateStore = ReSwift.Store(
            reducer: Reducers.GeoFenceDrawingReducer,
            state: GeoFenceDrawingViewControllerState(
                isEditable: isEditable,
                rule: rule,
                fenceShape: fenceShape
            )
        )
    }

    func makeGeoFenceDrawingViewController() -> GeoFenceDrawingViewController {
        let stateObservable = makeGeoFenceDrawingViewControllerStateObservable()
        let observer = ObserverForGeoFenceDrawing(state: stateObservable)
        let userInterface = GeoFenceDrawingRootView()
        let viewController = GeoFenceDrawingViewController(
            observer: observer,
            userInterface: userInterface,
            viewControllerFactory: self,
            composeGeoFenceUseCaseFactory: self,
            cleanGeoFenceUseCaseFactory: self,
            saveGeoFenceUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension GeoFenceDrawingDependencyContainer {

    func makeGeoFenceDrawingViewControllerStateObservable() -> Observable<GeoFenceDrawingViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension GeoFenceDrawingDependencyContainer: GeoFenceDrawingViewControllerFactory {

    func makeViewControllerForNextStep() -> UIViewController {
        let vc = GeoFenceRuleTypeAndScopeDependencyContainer(rule: stateStore.state.rule, enableTypeChoices: true).makeGeoFenceRuleTypeAndScopeViewController()
        return vc
    }

    func makeViewControllerForSearchingLocation() -> UIViewController {
        let vc = LocationPickerDependencyContainer(consumerActionDispatcher: actionDispatcher).makeLocationPickerViewController()
        return vc
    }

    func makeViewControllerForEditingRange() -> UIViewController? {
        let userInterface = MemberProfileInfoComposingRootView()

        if case .circle(_, let radius) = stateStore.state.shape {
            let radiusInMeters = Measurement(value: radius ?? 0, unit: UnitLength.meters).converted(to: .miles).value

            let viewController = MemberProfileInfoComposingViewController(
                memberProfileInfoType: .range("\(radiusInMeters)"),
                userInterface: userInterface,
                composingUseCaseFactory: self
            )
            userInterface.ixResponder = viewController

            return viewController
        }
        else {
            return nil
        }
    }

}

//MARK: - Use Case

extension GeoFenceDrawingDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<GeoFenceDrawingFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

    public func makeFinishedPresentingLocationPickerErrorUseCase(errorMessage: ErrorMessage) -> UseCase {
        let actionDispatcher = self.actionDispatcher
        let useCase = FinishedPresentingErrorUseCase<LocationPickerFinishedPresentingErrorAction>(
            errorMessage: errorMessage,
            actionDispatcher: actionDispatcher
        )
        return useCase
    }

}

extension GeoFenceDrawingDependencyContainer: ComposeGeoFenceUseCaseFactory {

    func makeComposeGeoFenceUseCase(composedData: Any) -> UseCase {
        return ComposeGeoFenceUseCase(composedData: composedData, actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceDrawingDependencyContainer: CleanGeoFenceUseCaseFactory {

    func makeCleanGeoFenceUseCase() -> UseCase {
        return CleanGeoFenceUseCase(actionDispatcher: actionDispatcher)
    }

}

extension GeoFenceDrawingDependencyContainer: SaveGeoFenceUseCaseFactory {

    func makeSaveGeoFenceUseCase() -> UseCase {
        return SaveGeoFenceUseCase(
            name: stateStore.state.rule.name!,
            shape: stateStore.state.shape!,
            actionDispatcher: actionDispatcher
        )
    }

}

extension GeoFenceDrawingDependencyContainer: ComposingMemberProfileInfoUseCaseFactory {

    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase {
        return ComposingProfileInfoUseCase(memberProfileInfoType: profileInfoType, actionDispatcher: actionDispatcher)
    }

}
