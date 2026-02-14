//
//  String+VersionCompare.swift
//  Acht
//
//  Created by forkon on 2021/10/13.
//  Copyright © 2019 waylens. All rights reserved.
//

extension String {

    func maskedApnString() -> String {
        return String(enumerated().map { (index, element) -> Character in
            if index != 0 && index != count - 1 {
                return "*"
            }
            return element
        })
    }

}
