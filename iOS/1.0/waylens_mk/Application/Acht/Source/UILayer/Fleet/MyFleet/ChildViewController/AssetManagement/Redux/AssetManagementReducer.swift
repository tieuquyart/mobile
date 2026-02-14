//
//  AssetManagementReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func AssetManagementReducer(action: Action, state: AssetManagementViewControllerState?) -> AssetManagementViewControllerState {
        let state = state ?? AssetManagementViewControllerState()

        return state
    }

}
