//
//  String+Bytes.swift
//  Acht
//
//  Created by Chester Shen on 2/1/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import Foundation

extension String {
    static func fromBytes(_ bytes: Int64, countStyle: ByteCountFormatter.CountStyle) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = countStyle
        let count = formatter.string(fromByteCount: bytes)
        return count
    }
}
