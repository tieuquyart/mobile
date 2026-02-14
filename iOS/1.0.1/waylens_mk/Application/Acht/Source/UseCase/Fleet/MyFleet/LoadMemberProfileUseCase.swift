//
//  LoadMemberProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadMemberProfileUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(MemberActions.loadMemberProfile)
    }

}

protocol LoadMemberProfileUseCaseFactory {
    func makeLoadMemberProfileUseCase() -> UseCase
}
