//
//  VinMirrorActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum VinMirrorActions: Action {
    case updateVinMirrors([VinMirror])
}

struct VinMirrorFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
