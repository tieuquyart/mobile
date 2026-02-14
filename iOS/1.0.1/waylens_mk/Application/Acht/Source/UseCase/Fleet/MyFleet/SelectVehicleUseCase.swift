//
//  SelectVehicleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SelectVehicleUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let selectedIndex: Int

    public init(
        selectedIndex: Int,
        actionDispatcher: ActionDispatcher
        ) {
        self.actionDispatcher = actionDispatcher
        self.selectedIndex = selectedIndex
    }

    public func start() {
        actionDispatcher.dispatch(VehicleListActions.selectVehicle(index: selectedIndex))
    }

}

protocol SelectVehicleUseCaseFactory {
    func makeSelectVehicleUseCase(selectedIndex: Int) -> UseCase
}
