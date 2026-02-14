//
//  String+VersionCompare.swift
//  Acht
//
//  Created by forkon on 2019/2/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias Version = String

extension String {

    func isNewerOrSameVersion(to anotherVersion: Version) -> Bool {
        return (compare(anotherVersion, options: NSString.CompareOptions.numeric) == .orderedDescending) || (compare(anotherVersion, options: NSString.CompareOptions.numeric) == .orderedSame)
    }

    func isNewer(than anotherVersion: Version) -> Bool {
        return (compare(anotherVersion, options: NSString.CompareOptions.numeric) == .orderedDescending)
    }

}
