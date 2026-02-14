//
//  ApplyDataFilterUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ApplyDataFilterUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private let dataFilter: DataFilter

    public init(dataFilter: DataFilter, actionDispatcher: ActionDispatcher) {
        self.dataFilter = dataFilter
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(DataFilterActions.applyFilter(dataFilter))
    }

}

protocol ApplyDataFilterUseCaseFactory {
    func makeApplyDataFilterUseCase(dataFilter: DataFilter) -> UseCase
}
