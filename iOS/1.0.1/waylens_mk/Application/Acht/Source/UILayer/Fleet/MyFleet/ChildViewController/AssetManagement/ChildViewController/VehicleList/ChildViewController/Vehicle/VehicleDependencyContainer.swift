//
//  VehicleDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class VehicleDependencyContainer {

    let stateStore: ReSwift.Store<VehicleViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(vehicleProfile: VehicleProfile) {
        stateStore = ReSwift.Store(reducer: Reducers.VehicleReducer, state: VehicleViewControllerState(vehicleProfile: vehicleProfile))
    }

    func makeVehicleViewController() -> VehicleViewController {
        let stateObservable = makeVehicleViewControllerStateObservable()
        let observer = ObserverForVehicle(state: stateObservable)
        let userInterface = VehicleRootView()
        let viewController = VehicleViewController(
            observer: observer,
            userInterface: userInterface,
            initialLoadUseCaseFactory: self,
            unbindCameraUseCaseFactory: self,
            profileViewControllerFactory: self,
            vehicleViewControllerFactory: self,
            removeVehicleUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: self.makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension VehicleDependencyContainer {

    func makeVehicleViewControllerStateObservable() -> Observable<VehicleViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension VehicleDependencyContainer: VehicleViewControllerFactory {

    func makeBindDriverViewController() -> UIViewController {
        return BindDriverDependencyContainer(vehicleDependencyContainer: self).makeBindDriverViewController()
    }

    func makeBindCameraViewController() -> UIViewController {
        return BindCameraDependencyContainer(vehicleDependencyContainer: self).makeBindCameraViewController()
    }

    func makeCameraDetailViewController() -> UIViewController {
        let vc = CameraDetailDependencyContainer(cameraSN: stateStore.state.vehicleProfile!.cameraSn, plateNumber: stateStore.state.vehicleProfile!.plateNo).makeCameraDetailViewController()
        return vc
    }
}

extension VehicleDependencyContainer: ProfileViewControllerFactory {

    func makeProfileInfoComposingViewController(with infoType: ProfileInfoType) -> UIViewController {
        
        let userInterface = MemberProfileInfoComposingRootView()

        var fixedInfoType: ProfileInfoType = infoType

        switch infoType {
        case .model:
            fixedInfoType = .model(stateStore.state.vehicleProfile?.type ?? "")
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

//MARK: - UseCase

extension VehicleDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<VehicleFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension VehicleDependencyContainer: InitialLoadUseCaseFactory {

    func makeInitialLoadUseCase() -> UseCase {
        return InitialLoadUseCase(actionDispatcher: actionDispatcher)
    }
}

extension VehicleDependencyContainer: UnbindCameraUseCaseFactory {

    func makeUnbindCameraUseCase() -> UseCase {
        let vehicleID = stateStore.state.vehicleProfile!.vehicleID
        let cameraSN = stateStore.state.vehicleProfile!.cameraSn
        return UnbindCameraUseCase(vehicleID: vehicleID!, cameraSN: cameraSN, actionDispatcher: actionDispatcher)
    }
}

extension VehicleDependencyContainer: ComposingMemberProfileInfoUseCaseFactory {

    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase {
        var profile = stateStore.state.vehicleProfile

        switch profileInfoType {
        case .model(let value):
            profile?.type = value
        default:
            break
        }

        let composingProfileInfoUseCase = ComposingProfileInfoUseCase(memberProfileInfoType: .model(profile!.type), actionDispatcher: self.actionDispatcher)

        return UpdateVehicleProfileUseCase(
            profile: profile!,
            actionDispatcher: actionDispatcher,
            composingProfileInfoUseCase: composingProfileInfoUseCase
        )
    }

}

extension VehicleDependencyContainer: RemoveVehicleUseCaseFactory {

    func makeRemoveVehicleUseCase() -> UseCase {
        return RemoveVehicleUseCase(vehicleID: stateStore.state.vehicleProfile!.vehicleID!, actionDispatcher: actionDispatcher)
    }

}
