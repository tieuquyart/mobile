//
//  NavigatedBackToMyFleetUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class NavigatedBackToMyFleetUseCase: UseCase {

    // MARK: - Properties
    let actionDispatcher: ActionDispatcher

    // MARK: - Methods
    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        let action = MyFleetActions.navigatedBackToMyFleet
        actionDispatcher.dispatch(action)
    }
}

public protocol NavigatedBackToMyFleetUseCaseFactory {

    func makeNavigatedBackToMyFleetUseCase() -> UseCase
}
