//
//  SelectLocationUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class SelectLocationUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let location: NamedLocation

    public init(location: NamedLocation, actionDispatcher: ActionDispatcher) {
        self.location = location
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(LocationPickerActions.locationSelected(location))
    }

}

protocol SelectLocationUseCaseFactory {
    func makeSelectLocationUseCase() -> UseCase
}
