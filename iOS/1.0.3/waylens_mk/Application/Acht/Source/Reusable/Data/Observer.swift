//
//  Observer.swift
//  Acht
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public protocol Observer {
    func startObserving()
    func stopObserving()
}

class ObserverComposition: Observer {
    // MARK: - Properties
    let observers: [Observer]
    
    // MARK: - Methods
    init(observers: Observer...) {
        self.observers = observers
    }

    func startObserving() { observers.forEach {
        $0.startObserving() }
    }

    func stopObserving() { observers.forEach {
        $0.stopObserving() }
    }
}
