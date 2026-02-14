//
//  ErrorActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum ErrorActions: ReSwift.Action {
    case failedToProcess(errorMessage: ErrorMessage)
}
