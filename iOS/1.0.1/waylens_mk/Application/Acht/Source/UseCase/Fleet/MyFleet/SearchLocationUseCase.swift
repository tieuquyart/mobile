//
//  SearchLocationUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class SearchLocationUseCase: UseCase {
    let query: String
    let actionDispatcher: ActionDispatcher
    let locationRepository: LocationRepository

    public init(
        query: String,
        actionDispatcher: ActionDispatcher,
        locationRepository: LocationRepository
    ) {
        self.query = query
        self.actionDispatcher = actionDispatcher
        self.locationRepository = locationRepository
    }

    public func start() {
        locationRepository
            .searchForLocations(using: query)
            .done { searchResults in
                self.update(searchResults: searchResults)
        }
        .catch { error in

        }
    }

    private func update(searchResults: [NamedLocation]) {
        let action = LocationPickerActions.locationSearchComplete(searchResults: searchResults)
        actionDispatcher.dispatch(action)
    }
}

protocol SearchLocationUseCaseFactory {
    func makeSearchLocationUseCase(query: String) -> UseCase
}
