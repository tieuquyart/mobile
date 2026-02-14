//
//  MyFleetReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func myFleetReducer(action: Action, state: MyFleetViewControllerState?) -> MyFleetViewControllerState {
        var state = state ?? MyFleetViewControllerState()

        if let userProfile = UserSetting.current.userProfile {
            //change by thanh
            state.userProfile = userProfile
        }
        

        return state
    }

}
