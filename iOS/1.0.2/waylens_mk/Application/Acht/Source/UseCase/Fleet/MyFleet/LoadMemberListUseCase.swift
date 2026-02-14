//
//  LoadMemberListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadMemberListUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let personnelManagementRepository: PersonnelManagementRepository

    public init(
        personnelManagementRepository: PersonnelManagementRepository,
        actionDispatcher: ActionDispatcher
        ) {
        self.actionDispatcher = actionDispatcher
        self.personnelManagementRepository = personnelManagementRepository
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))
        personnelManagementRepository.loadMemberList { (members, error) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
            if let members = members {
                self.actionDispatcher.dispatch(PersonnelManagementActions.loadMembers(members))
            } else {
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol LoadMemberListUseCaseFactory {
    func makeLoadMemberListUseCase() -> LoadMemberListUseCase
}
