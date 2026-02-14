//
//  JSONAble.swift
//  Acht
//
//  Created by forkon on 2020/3/3.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

protocol JSONAble {}

extension JSONAble {

    func asDictionary() -> [String : Any] {
        var dict = [String : Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }

}
