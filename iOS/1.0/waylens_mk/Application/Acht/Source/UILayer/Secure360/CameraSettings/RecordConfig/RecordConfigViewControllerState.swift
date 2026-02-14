//
//  RecordConfigViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public typealias RecordConfig = String

public struct RecordConfigViewControllerState: ReSwift.StateType, Equatable {
    public var items: [WLEvcamRecordConfigListItem] = []
    public var selectedItem: WLCameraRecordConfig? = nil
    public var willSelectedItem: WLEvcamRecordConfigListItem? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: RecordConfigViewState = RecordConfigViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct RecordConfigViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
