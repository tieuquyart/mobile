//
//  FinishComposingUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FinishComposingUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {

    }

}

protocol FinishComposingUseCaseFactory {
    func makeFinishComposingUseCase() -> UseCase
}
