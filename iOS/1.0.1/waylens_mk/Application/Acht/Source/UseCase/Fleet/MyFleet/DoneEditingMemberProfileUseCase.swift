//
//  DoneEditingMemberProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DoneEditingMemberProfileUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(MemberActions.doneEditingMemberProfile)
    }

}

protocol DoneEditingMemberProfileUseCaseFactory {
    func makeDoneEditingMemberProfileUseCase() -> UseCase
}
