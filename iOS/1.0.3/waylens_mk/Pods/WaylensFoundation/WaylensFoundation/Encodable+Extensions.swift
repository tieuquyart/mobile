//
//  Encodable+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/2/27.
//  Copyright © 2020 waylens. All rights reserved.
//

extension Encodable {

    public func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

}
