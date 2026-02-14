//
//  MyFleetSettingsViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct MyFleetSettingsViewControllerState: ReSwift.StateType, Equatable {

    var viewState: MyFleetSettingsViewState = MyFleetSettingsViewState()

}

public struct MyFleetSettingsViewState: Equatable {

    var isDebugOptionsEnable: Bool {
        return  UserSetting.shared.debugEnabled
        //(UserSetting.current.userProfile?.roles.contains(.developer) == true) ||
       
    }

}
