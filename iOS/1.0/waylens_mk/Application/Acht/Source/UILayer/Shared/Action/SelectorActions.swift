//
//  SelectorActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/14.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum SelectorActions: ReSwift.Action {
    case select(IndexPath)
    case finish(Any?)
}
