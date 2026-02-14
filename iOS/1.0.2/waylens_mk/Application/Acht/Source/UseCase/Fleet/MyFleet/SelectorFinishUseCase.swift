//
//  SelectorFinishUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SelectorFinishUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let selectedItem: Any?

    public init(
        selectedItem: Any?,
        actionDispatcher: ActionDispatcher
        ) {
        self.selectedItem = selectedItem
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(SelectorActions.finish(selectedItem))
    }

}

protocol SelectorFinishUseCaseFactory {
    func makeSelectorFinishUseCase() -> UseCase
}
