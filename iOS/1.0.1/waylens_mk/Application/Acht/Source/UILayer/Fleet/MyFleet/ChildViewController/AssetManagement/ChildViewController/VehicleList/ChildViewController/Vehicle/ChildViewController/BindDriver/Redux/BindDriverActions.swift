//
//  BindDriverActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum BindDriverActions: Action {
    case failToBind(errorMessage: ErrorMessage)
}

struct BindDriverFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
