//
//  Dictionary+Merging.swift
//  Acht
//
//  Created by Chester Shen on 11/15/17.
//  Copyright © 2017 waylens. All rights reserved.
//

extension Dictionary {
    public func merged(another: [Key: Any]) -> [Key:Any] {
        var result = [Key: Any]()
        for (key, value) in self {
            result[key] = value
        }
        for (key, value) in another {
            if let subDict = result[key] as? Dictionary,
               let anotherSubDict = value as? Dictionary {
                let newValue = subDict.merged(another: anotherSubDict)
                result[key] = newValue
            } else if let subArray = result[key] as? [Any],
                let anotherSubArray = value as? [Any] {
                var mergedArray: [Any] = Array(subArray)
                mergedArray.append(contentsOf: anotherSubArray)
                result[key] = mergedArray
            } else {
                result[key] = value
            }
        }
        return result
    }
    
    public func dried() -> [Key:Any] {
        let this = self as [Key: Any?]
        var result = [Key: Any]()
        for (key, value) in this {
            guard let value = value else { continue }
            if let dict = value as? Dictionary {
                result[key] = dict.dried()
            } else {
                result[key] = value
            }
        }
        return result
    }
}

extension Dictionary {

    public var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }

}
