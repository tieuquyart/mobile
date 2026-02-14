//
//  AddNewGeoFenceDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AddNewGeoFenceDependencyContainer {

    let stateStore: ReSwift.Store<AddNewGeoFenceViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(rule: GeoFenceRuleForEdit? = nil, fence: GeoFence? = nil) {
        stateStore = ReSwift.Store(reducer: Reducers.AddNewGeoFenceReducer, state: AddNewGeoFenceViewControllerState(rule: rule, fence: fence))
    }

    func makeAddNewGeoFenceViewController() -> AddNewGeoFenceViewController {
        let stateObservable = makeAddNewGeoFenceViewControllerStateObservable()
        let observer = ObserverForAddNewGeoFence(state: stateObservable)
        let userInterface = AddNewGeoFenceRootView()
        let viewController = AddNewGeoFenceViewController(
            observer: observer,
            userInterface: userInterface,
            editGeoFenceRuleUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            checkIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory: stateStore.state.rule.fenceRuleID != nil ? nil : self,
            checkIfExistSameNameGeoFenceRuleUseCaseFactory: self,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension AddNewGeoFenceDependencyContainer {

    func makeAddNewGeoFenceViewControllerStateObservable() -> Observable<AddNewGeoFenceViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension AddNewGeoFenceDependencyContainer: AddNewGeoFenceViewControllerFactory {

    func makeNextStepViewController() -> UIViewController? {
        switch stateStore.state.viewState.selectedElement {
        case .typeCircular:
            var fenceShape: GeoFenceShapeForEdit

            if case .circle(let center, let radius) = stateStore.state.fence?.shape {
                fenceShape = .circle(center: center, radius: radius)
            }
            else {
                fenceShape = .circle(center: nil, radius: Measurement(value: 10, unit: UnitLength.miles).converted(to: UnitLength.meters).value)
            }

            return GeoFenceDrawingDependencyContainer(
                isEditable: stateStore.state.rule.fenceID == nil ? true : false,
                rule: stateStore.state.rule,
                fenceShape: fenceShape
            ).makeGeoFenceDrawingViewController()
        case .typePolygonal:
            let fenceShape: GeoFenceShapeForEdit

            if case .polygon(let points) = stateStore.state.fence?.shape {
                fenceShape = .polygon(points: points)
            }
            else {
                fenceShape = .polygon(points: nil)
            }

            return GeoFenceDrawingDependencyContainer(
                isEditable: stateStore.state.rule.fenceID == nil ? true : false,
                rule: stateStore.state.rule,
                fenceShape: fenceShape
            ).makeGeoFenceDrawingViewController()
        default:
            return GeoFenceListDependencyContainer(rule: stateStore.state.rule).makeGeoFenceListViewController()
        }
    }

}

//MARK: - Use Case

extension AddNewGeoFenceDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<AddNewGeoFenceFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension AddNewGeoFenceDependencyContainer: EditGeoFenceRuleUseCaseFactory {

    func makeEditGeoFenceRuleUseCase(_ reducer: @escaping (inout GeoFenceRuleForEdit) -> ()) -> UseCase {
        return EditGeoFenceRuleUseCase(rule: stateStore.state.rule, reducer: reducer, actionDispatcher: actionDispatcher)
    }

}

extension AddNewGeoFenceDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }

}

extension AddNewGeoFenceDependencyContainer: CheckIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory {

    func makeCheckIfReachLimitOfGeoFenceRuleQuantityUseCase(completion: @escaping CheckIfReachLimitOfGeoFenceRuleQuantityUseCase.Completion) -> UseCase {
        return CheckIfReachLimitOfGeoFenceRuleQuantityUseCase(
            actionDispatcher: actionDispatcher,
            completion: completion
        )
    }

}

extension AddNewGeoFenceDependencyContainer: CheckIfExistSameNameGeoFenceRuleUseCaseFactory {

    func makeCheckIfExistSameNameGeoFenceRuleUseCase(completion: @escaping CheckIfExistSameNameGeoFenceRuleUseCase.Completion) -> UseCase {
        if stateStore.state.rule.fenceRuleID != nil, stateStore.state.rule == stateStore.state.ruleBeforeEdit {
            return CheckIfExistSameNameGeoFenceRuleUseCase(
                rule: GeoFenceRuleForEdit(),
                actionDispatcher: actionDispatcher,
                completion: completion
            )
        }
        else {
            return CheckIfExistSameNameGeoFenceRuleUseCase(
                rule: stateStore.state.rule,
                actionDispatcher: actionDispatcher,
                completion: completion
            )
        }

    }

}

