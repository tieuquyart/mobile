//
//  EditGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class EditGeoFenceRuleUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private var rule: GeoFenceRuleForEdit
    private var reducer: GeoFenceRuleReducer

    public init(rule: GeoFenceRuleForEdit, reducer: @escaping GeoFenceRuleReducer, actionDispatcher: ActionDispatcher) {
        self.rule = rule
        self.reducer = reducer
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        reducer(&rule)
        actionDispatcher.dispatch(AddNewGeoFenceActions.editedGeoFenceRule(rule))
    }

}

protocol EditGeoFenceRuleUseCaseFactory {
    func makeEditGeoFenceRuleUseCase(_ reducer: @escaping GeoFenceRuleReducer) -> UseCase
}
