//
//  SetupVehicleDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class SetupVehicleDependencyContainer {

    let stateStore: ReSwift.Store<SetupVehicleViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.SetupVehicleReducer, state: SetupVehicleViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeSetupVehicleViewController() -> SetupVehicleViewController {
        let stateObservable = makeSetupVehicleViewControllerStateObservable()
        let observer = ObserverForSetupVehicle(state: stateObservable)
        let userInterface = SetupVehicleRootView()
        let viewController = SetupVehicleViewController(
            observer: observer,
            userInterface: userInterface,
            addNewVehicleViewControllerFactory: self,
            makeAddNewCameraViewController: makeAddNewCameraViewController,
            profileViewControllerFactory: self,
            loadCameraListUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            updateVehicleProfileUseCaseFactory: self,
            bindCameraUseCaseFactory: self,
            bindDriverUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension SetupVehicleDependencyContainer {

    func makeSetupVehicleViewControllerStateObservable() -> Observable<SetupVehicleViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension SetupVehicleDependencyContainer: SetupVehicleViewControllerFactory {

    func makeDriverSelectorViewController() -> UIViewController {
       
        let state = stateStore.state
        let vehicleProfile = VehicleProfile(
            vehicleID: state?.vehicleProfile.vehicleID ?? "",
            cameraSn: state?.selectedCamera?.cameraSn ?? "",
            plateNo: state?.vehicleProfile.plateNo ?? "",
            type: state?.vehicleProfile.type ?? "",
            driverID: state?.selectedDriver?.driverID,
            userID: "",
            name: nil,
            verified: false
        )

        return DriverSelectorDependencyContainer(
            vehicleProfile: vehicleProfile,
            consumerActionDispatcher: actionDispatcher
            ).makeDriverSelectorViewController()
    }
}

extension SetupVehicleDependencyContainer: ProfileViewControllerFactory {

    func makeProfileInfoComposingViewController(with infoType: ProfileInfoType) -> UIViewController {
        let userInterface = MemberProfileInfoComposingRootView()

        switch infoType {
        case .model:
            let fixedInfoType: ProfileInfoType = .model(stateStore.state.vehicleProfile.type)

            let viewController = MemberProfileInfoComposingViewController(
                memberProfileInfoType: fixedInfoType,
                userInterface: userInterface,
                composingUseCaseFactory: self
            )
            userInterface.ixResponder = viewController

            return viewController
        case .plateNumber:
            let viewController = VehicleSelectorDependencyContainer(vehicleProfile: stateStore.state.vehicleProfile, consumerActionDispatcher: actionDispatcher).makeVehicleSelectorViewController()
            return viewController
        default:
            fatalError()
        }
    }

}

extension SetupVehicleDependencyContainer {

    func makeAddNewCameraViewController() -> UIViewController {
        return AddNewCameraDependencyContainer().makeAddNewCameraViewController().embedInNavigationController()
    }
}

//MARK: - Use Case

extension SetupVehicleDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<SetupVehicleFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension SetupVehicleDependencyContainer: LoadCameraListUseCaseFactory {

    func makeLoadCameraListUseCase() -> UseCase {
        return LoadCameraListUseCase(actionDispatcher: actionDispatcher)
    }
}

extension SetupVehicleDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }
}

extension SetupVehicleDependencyContainer: ComposingMemberProfileInfoUseCaseFactory {

    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase {
        return ComposingProfileInfoUseCase(memberProfileInfoType: profileInfoType, actionDispatcher: actionDispatcher)
    }

}

extension SetupVehicleDependencyContainer: UpdateVehicleProfileUseCaseFactory {

    func makeUpdateVehicleProfileUseCase() -> UseCase {
        return UpdateVehicleProfileUseCase(
            profile: stateStore.state.vehicleProfile,
            actionDispatcher: actionDispatcher
        )
    }

}

extension SetupVehicleDependencyContainer: BindCameraUseCaseFactory {

    func makeBindCameraUseCase() -> UseCase {
        let selectedCamera = stateStore.state.selectedCamera

        return BindCameraUseCase(
            vehicleID: stateStore.state.vehicleProfile.vehicleID!,
            cameraSN: selectedCamera!.cameraSn,
            actionDispatcher: actionDispatcher,
            vehicleActionDispatcher: actionDispatcher
        )
    }

}

extension SetupVehicleDependencyContainer: BindDriverUseCaseFactory {

    func makeBindDriverUseCase() -> UseCase {
        let selectedDriver = stateStore.state.selectedDriver

        return UpdateDriverBindingUseCase(
            vehicleID: stateStore.state.vehicleProfile.vehicleID!,
            driver: selectedDriver!,
            actionDispatcher: actionDispatcher,
            vehicleActionDispatcher: actionDispatcher
        )
    }
}
