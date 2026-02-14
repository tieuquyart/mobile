//
//  FirstLaunch.swift
//  Acht
//
//  Created by forkon on 2019/4/22.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

final class FirstLaunch {

    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }

    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }

    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }

}
