//
//  FinishedPresentingErrorAction.swift
//  Acht
//
//  Created by forkon on 2019/11/10.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation
import ReSwift

public protocol FinishedPresentingErrorAction: ReSwift.Action {

    init(errorMessage: ErrorMessage)
}
