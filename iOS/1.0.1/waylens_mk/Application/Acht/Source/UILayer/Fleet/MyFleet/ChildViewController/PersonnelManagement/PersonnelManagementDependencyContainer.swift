//
//  PersonnelManagementDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class PersonnelManagementDependencyContainer {

    let stateStore: ReSwift.Store<PersonnelManagementViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.PersonnelManagementReducer, state: PersonnelManagementViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makePersonnelManagementViewController() -> PersonnelManagementViewController {
        let stateObservable = makePersonnelManagementViewControllerStateObservable()
        let observer = ObserverForPersonnelManagement(state: stateObservable)
        let userInterface = PersonnelManagementRootView()
        let viewController = PersonnelManagementViewController(
            observer: observer,
            userInterface: userInterface,
            loadMemberListUseCaseFactory: self,
            viewControllerFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension PersonnelManagementDependencyContainer {

    func makePersonnelManagementViewControllerStateObservable() -> Observable<PersonnelManagementViewControllerState> {
        return stateStore.makeObservable()
    }

}

extension PersonnelManagementDependencyContainer: PersonnelManagementViewControllerFactory {

    func makeMemberViewController(with member: FleetMember?) -> UIViewController {
        return MemberDependencyContainer(memberProfile: member).makeMemberViewController()
    }

}

extension PersonnelManagementDependencyContainer: LoadMemberListUseCaseFactory {

    func makeLoadMemberListUseCase() -> LoadMemberListUseCase {
        return LoadMemberListUseCase(personnelManagementRepository: PersonnelManagementRepository(), actionDispatcher: actionDispatcher)
    }

}

extension PersonnelManagementDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<PersonnelManagementFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}
