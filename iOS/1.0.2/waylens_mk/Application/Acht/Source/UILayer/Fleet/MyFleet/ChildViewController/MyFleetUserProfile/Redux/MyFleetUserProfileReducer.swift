//
//  MyFleetUserProfileReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func MyFleetUserProfileReducer(action: Action, state: MyFleetUserProfileViewControllerState?) -> MyFleetUserProfileViewControllerState {
        let state = state ?? MyFleetUserProfileViewControllerState()

        return state
    }

}
