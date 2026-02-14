//
//  FinishedPresentingErrorUseCase.swift
//  Acht
//
//  Created by forkon on 2019/11/10.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation
import PromiseKit
import ReSwift

public class FinishedPresentingErrorUseCase<Action: FinishedPresentingErrorAction>: UseCase {

    // MARK: - Properties
    // Input data
    let errorMessage: ErrorMessage

    // Redux action dispatcher
    let actionDispatcher: ActionDispatcher

    // MARK: - Methods
    public init(
        errorMessage: ErrorMessage,
        actionDispatcher: ActionDispatcher
        ) {
        self.errorMessage = errorMessage
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        assert(Thread.isMainThread)
        let action = Action(errorMessage: errorMessage)
        actionDispatcher.dispatch(action)
    }
}

public typealias FinishedPresentingErrorUseCaseFactory = (ErrorMessage) -> UseCase
