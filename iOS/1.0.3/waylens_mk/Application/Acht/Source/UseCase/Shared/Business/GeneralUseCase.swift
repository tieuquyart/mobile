//
//  GeneralUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class GeneralUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    let value: Any

    public init(value: Any, actionDispatcher: ActionDispatcher) {
        self.value = value
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(GeneralAction(value: value))
    }

}

protocol GeneralUseCaseFactory {
    func makeGeneralUseCase(value: Any) -> UseCase
}
