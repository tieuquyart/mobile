//
//  ReloadUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class InitialLoadUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(InitialLoadAction())
    }

}

protocol InitialLoadUseCaseFactory {
    func makeInitialLoadUseCase() -> UseCase
}
