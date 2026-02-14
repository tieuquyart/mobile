//
//  UInt64+Extensions.swift
//  WaylensFoundation
//
//  Created by forkon on 2021/1/20.
//  Copyright © 2021 Waylens. All rights reserved.
//

import Foundation

fileprivate let maskLowerBits = (UInt64(1) << 32) - 1
fileprivate let maskHigherBits = maskLowerBits << 32

extension UInt64 {



}

extension UInt64: WaylensSpacable {}

public extension WaylensSpace where Base == UInt64 {

    var halfShift: UInt64 {
        return UInt64(UInt64.bitWidth / 2)

    }

    var high: UInt64 {
        return self.base >> 32
    }

    var low: UInt64 {
        return self.base & maskLowerBits
    }

    var upshifted: UInt64 {
        return self.base << 32
    }

    var split: (high: UInt64, low: UInt64) {
        return (self.high, self.low)
    }

    init(_ value: (high: UInt64, low: UInt64)) {
        self.base = value.high.wl.upshifted + value.low
    }
}
