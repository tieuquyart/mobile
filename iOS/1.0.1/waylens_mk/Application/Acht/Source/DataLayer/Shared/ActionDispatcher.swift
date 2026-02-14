//
//  ActionDispatcher.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

public protocol ActionDispatcher {

    func dispatch(_ action: Action)
    
}

extension ReSwift.Store: ActionDispatcher {}

