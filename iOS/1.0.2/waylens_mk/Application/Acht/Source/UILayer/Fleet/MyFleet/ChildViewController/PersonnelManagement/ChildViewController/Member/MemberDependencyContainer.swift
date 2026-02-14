//
//  MemberDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class MemberDependencyContainer {

    let stateStore: ReSwift.Store<MemberViewControllerState>

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init(memberProfile: MemberProfile?) {
        let profile: MemberProfile
        
        if let memberProfile = memberProfile {
            profile = memberProfile
        } else {
            profile = MemberProfile(name: "", roles: .driver, email: nil, phoneNumber: nil)
        }

        let scene: MemberViewControllerScene = (memberProfile != nil) ? .viewing(isEditing: false) : .addingNew

        stateStore = ReSwift.Store(reducer: Reducers.MemberReducer, state: MemberViewControllerState(memberProfile: profile, scene: scene))
    }

    func makeMemberViewController() -> MemberViewController {
        let stateObservable = makeMemberViewControllerStateObservable()
        let observer = ObserverForMember(state: stateObservable)
        let userInterface = MemberRootView()
        let viewController = MemberViewController(
            observer: observer,
            userInterface: userInterface,
            loadMemberProfileUseCaseFactory: self,
            memberViewControllerFactory: self,
            beginEditingMemberProfileUseCaseFactory: self,
            doneEditingMemberProfileUseCaseFactory: self,
            saveNewMemberUseCaseFactory: self,
            removeMemberUseCaseFactory: self,
            updateMemberProfileUseCaseFactory: self,
            changeFleetOwnerUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: self.makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension MemberDependencyContainer {

    func makeMemberViewControllerStateObservable() -> Observable<MemberViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension MemberDependencyContainer: LoadMemberProfileUseCaseFactory {

    func makeLoadMemberProfileUseCase() -> UseCase {
        return LoadMemberProfileUseCase(actionDispatcher: actionDispatcher)
    }

}

extension MemberDependencyContainer: BeginEditingMemberProfileUseCaseFactory, DoneEditingMemberProfileUseCaseFactory {

    func makeBeginEditingMemberProfileUseCase() -> UseCase {
        return BeginEditingMemberProfileUseCase(actionDispatcher: actionDispatcher)
    }

    func makeDoneEditingMemberProfileUseCase() -> UseCase {
        return DoneEditingMemberProfileUseCase(actionDispatcher: actionDispatcher)
    }

}

extension MemberDependencyContainer: SaveNewMemberUseCaseFactory, RemoveMemberUseCaseFactory {

    func makeSaveNewMemberUseCase() -> UseCase {
        return SaveNewMemberUseCase(member: stateStore.state.memberProfile, actionDispatcher: actionDispatcher)
    }

    func makeRemoveMemberUseCase() -> UseCase {
        return RemoveMemberUseCase(member: stateStore.state.memberProfile, actionDispatcher: actionDispatcher)
    }
}

extension MemberDependencyContainer: UpdateMemberProfileUseCaseFactory {

    func makeUpdateMemberProfileUseCase() -> UseCase {
        return UpdateMemberProfileUseCase(member: stateStore.state.memberProfile, actionDispatcher: actionDispatcher)
    }
}

extension MemberDependencyContainer: ChangeFleetOwnerUseCaseFactory {

    func makeChangeFleetOwnerUseCase(password: String) -> UseCase {
        return ChangeFleetOwnerUseCase(
            targetOwnerEmail: stateStore.state.memberProfile.email!,
            currentOwnerPassword: password,
            actionDispatcher: actionDispatcher
        )
    }
}

extension MemberDependencyContainer: ProfileViewControllerFactory {

    func makeProfileInfoComposingViewController(with infoType: ProfileInfoType) -> UIViewController {
        let userInterface = MemberProfileInfoComposingRootView()

        var fixedInfoType: ProfileInfoType = infoType

        switch infoType {
        case .name:
            fixedInfoType = .name(stateStore.state.memberProfile.getName())
        case .user_name:
            fixedInfoType = .user_name(stateStore.state.memberProfile.get_userName())
        case .role:
            fixedInfoType = .role(stateStore.state.memberProfile.roles)
        case .email:
            fixedInfoType = .email(stateStore.state.memberProfile.email ?? "")
        case .phoneNumber:
            fixedInfoType = .phoneNumber(stateStore.state.memberProfile.phoneNumber ?? "")
        default:
            break
        }
//
        let viewController = MemberProfileInfoComposingViewController(
            memberProfileInfoType: fixedInfoType,
            userInterface: userInterface,
            composingUseCaseFactory: self
        )
        userInterface.ixResponder = viewController
//
        if  infoType.description == "Role" {
            let viewController  = RoleListViewController()
            viewController.userId = stateStore.state.memberProfile.get_id()
            viewController.roleName = stateStore.state.memberProfile.roleNames
            return viewController
        } else {
            return viewController
        }
      
    }

}


extension MemberDependencyContainer: ComposingMemberProfileInfoUseCaseFactory {

    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase {
        return ComposingProfileInfoUseCase(memberProfileInfoType: profileInfoType, actionDispatcher: actionDispatcher)
    }

}

extension MemberDependencyContainer {

    public func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<MemberFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}
