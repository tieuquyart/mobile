//
//  ReloadUserProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ReloadUserProfileUseCase: UseCase {

    // MARK: - Properties
    let actionDispatcher: ActionDispatcher

    // MARK: - Methods
    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        let action = MyFleetActions.reloadUserProfile
        actionDispatcher.dispatch(action)
    }

}

protocol ReloadUserProfileUseCaseFactory {
    func makeReloadUserProfileUseCase() -> UseCase
}
