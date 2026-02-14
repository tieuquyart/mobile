//
//  SelectorSelectUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SelectorSelectUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let indexPath: IndexPath

    public init(
        indexPath: IndexPath,
        actionDispatcher: ActionDispatcher
        ) {
        self.indexPath = indexPath
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(SelectorActions.select(indexPath))
    }

}

protocol SelectorSelectUseCaseFactory {
    func makeSelectorSelectUseCase(indexPath: IndexPath) -> UseCase
}
