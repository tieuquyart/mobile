//
//  LoadedState.swift
//  Fleet
//
//  Created by forkon on 2020/5/13.
//  Copyright © 2020 waylens. All rights reserved.
//

public enum LoadedState<T: Equatable>: Equatable {
    case notLoaded
    case loaded(state: T)
}
