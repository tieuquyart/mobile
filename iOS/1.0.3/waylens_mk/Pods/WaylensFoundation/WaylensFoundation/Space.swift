//
//  WaylensSpacable.swift
//  Acht
//
//  Created by forkon on 2020/8/18.
//  Copyright © 2020 waylens. All rights reserved.
//

public protocol WaylensSpacable {
    associatedtype CompatibleType
    static var wl: WaylensSpace<CompatibleType>.Type { get }
    var wl: WaylensSpace<CompatibleType> { get }
}

extension WaylensSpacable {
    public static var wl: WaylensSpace<Self>.Type {
        get {
            return WaylensSpace<Self>.self
        }
    }

    public var wl: WaylensSpace<Self> {
        get {
            return WaylensSpace(self)
        }
    }
}

public struct WaylensSpace<Base> {
    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

extension NSObject: WaylensSpacable {}
