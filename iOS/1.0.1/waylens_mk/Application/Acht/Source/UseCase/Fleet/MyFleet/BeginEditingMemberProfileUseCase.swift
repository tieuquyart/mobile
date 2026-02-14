//
//  BeginEditingMemberProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BeginEditingMemberProfileUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(MemberActions.beginEditingMemberProfile)
    }

}

protocol BeginEditingMemberProfileUseCaseFactory {
    func makeBeginEditingMemberProfileUseCase() -> UseCase
}
