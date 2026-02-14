//
//  AlertSettingsDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AlertSettingsDependencyContainer {

    let stateStore: ReSwift.Store<AlertSettingsViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AlertSettingsReducer, state: AlertSettingsViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAlertSettingsViewController() -> AlertSettingsViewController {
        let stateObservable = makeAlertSettingsViewControllerStateObservable()
        let observer = ObserverForAlertSettings(state: stateObservable)
        let userInterface = AlertSettingsRootView()
        let viewController = AlertSettingsViewController(
            observer: observer,
            userInterface: userInterface,
            loadAlertSettingsUseCaseFactory: self,
            toggleAlertSettingUseCaseFactory: self,
            saveAlertSettingsUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

extension AlertSettingsDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<AlertSettingsFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

private extension AlertSettingsDependencyContainer {

    func makeAlertSettingsViewControllerStateObservable() -> Observable<AlertSettingsViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension AlertSettingsDependencyContainer: LoadAlertSettingsUseCaseFactory {

    func makeLoadAlertSettingsUseCase() -> UseCase {
        return LoadAlertSettingsUseCase(actionDispatcher: actionDispatcher)
    }

}

extension AlertSettingsDependencyContainer: ToggleAlertSettingUseCaseFactory {

    func makeToggleAlertSettingUseCase(alertSetting: AlertSettingSet, isOn: Bool) -> UseCase {
        return ToggleAlertSettingUseCase(alertSetting: alertSetting, isOn: isOn, actionDispatcher: actionDispatcher)
    }

}

extension AlertSettingsDependencyContainer: SaveAlertSettingsUseCaseFactory {

    func makeSaveAlertSettingsUseCase() -> UseCase {
        return SaveAlertSettingsUseCase(alertSettings: stateStore.state.disabledAlertSettings, actionDispatcher: actionDispatcher)
    }

}
