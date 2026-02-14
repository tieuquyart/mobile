//
//  AddNewVehicleDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class AddNewVehicleDependencyContainer {

    let stateStore: ReSwift.Store<AddNewVehicleViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.AddNewVehicleReducer, state: AddNewVehicleViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeAddNewVehicleViewController() -> AddNewVehicleViewController {
        let stateObservable = makeAddNewVehicleViewControllerStateObservable()
        let observer = ObserverForAddNewVehicle(state: stateObservable)
        let userInterface = AddNewVehicleRootView()
        let viewController = AddNewVehicleViewController(
            observer: observer,
            userInterface: userInterface,
            addNewVehicleViewControllerFactory: self,
            makeAddNewCameraViewController: makeAddNewCameraViewController,
            profileViewControllerFactory: self,
            loadCameraListUseCaseFactory: self,
            selectorSelectUseCaseFactory: self,
            addNewVehicleUseCaseFactory: self,
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

private extension AddNewVehicleDependencyContainer {

    func makeAddNewVehicleViewControllerStateObservable() -> Observable<AddNewVehicleViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension AddNewVehicleDependencyContainer: AddNewVehicleViewControllerFactory {

    func makeDriverSelectorViewController() -> UIViewController {
     
        let state = stateStore.state
        let vehicleProfile = VehicleProfile(
            vehicleID: state?.vehicleProfile.vehicleID ?? "",
            cameraSn: state?.selectedCamera?.cameraSn ?? "",
            plateNo: state?.vehicleProfile.plateNo ?? "",
            type: state?.vehicleProfile.type ?? "",
            driverID: state?.selectedDriver?.driverID ?? "",
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

extension AddNewVehicleDependencyContainer: ProfileViewControllerFactory {

    func makeProfileInfoComposingViewController(with infoType: ProfileInfoType) -> UIViewController {
        let userInterface = MemberProfileInfoComposingRootView()

        var fixedInfoType: ProfileInfoType = infoType

        switch infoType {
        case .model:
            fixedInfoType = .model(stateStore.state.vehicleProfile.type)
        case .plateNumber:
            fixedInfoType = .plateNumber(stateStore.state.vehicleProfile.plateNo)
        default:
            break
        }

        let viewController = MemberProfileInfoComposingViewController(
            memberProfileInfoType: fixedInfoType,
            userInterface: userInterface,
            composingUseCaseFactory: self
        )
        userInterface.ixResponder = viewController

        return viewController
    }

}

extension AddNewVehicleDependencyContainer {

    func makeAddNewCameraViewController() -> UIViewController {
        return AddNewCameraDependencyContainer().makeAddNewCameraViewController().embedInNavigationController()
    }
}

//MARK: - Use Case

extension AddNewVehicleDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<AddNewVehicleFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension AddNewVehicleDependencyContainer: LoadCameraListUseCaseFactory {

    func makeLoadCameraListUseCase() -> UseCase {
        return LoadCameraListUseCase(actionDispatcher: actionDispatcher)
    }
}

extension AddNewVehicleDependencyContainer: SelectorSelectUseCaseFactory {

    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase {
        return SelectorSelectUseCase(indexPath: indexPath, actionDispatcher: actionDispatcher)
    }
}

extension AddNewVehicleDependencyContainer: ComposingMemberProfileInfoUseCaseFactory {

    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase {
        return ComposingProfileInfoUseCase(memberProfileInfoType: profileInfoType, actionDispatcher: actionDispatcher)
    }

}

extension AddNewVehicleDependencyContainer: AddNewVehicleUseCaseFactory {

    func makeAddNewVehicleUseCase() -> UseCase {
        return AddNewVehicleUseCase(
            plateNumber: stateStore.state.vehicleProfile.plateNo,
            model: stateStore.state.vehicleProfile.type,
            actionDispatcher: actionDispatcher
        )
    }
}

extension AddNewVehicleDependencyContainer: BindCameraUseCaseFactory {

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

extension AddNewVehicleDependencyContainer: BindDriverUseCaseFactory {

    func makeBindDriverUseCase() -> UseCase {
        let selectedDriver = stateStore.state.selectedDriver

        return BindDriverUseCase(
            vehicleID: stateStore.state.vehicleProfile.vehicleID!,
            driver: selectedDriver!,
            actionDispatcher: actionDispatcher,
            vehicleActionDispatcher: actionDispatcher
        )
    }
}
