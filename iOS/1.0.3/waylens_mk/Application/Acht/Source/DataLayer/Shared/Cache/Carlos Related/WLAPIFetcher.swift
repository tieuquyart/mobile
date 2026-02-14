//
//  WLAPIFetcher.swift
//  Acht
//
//  Created by Chester Shen on 12/27/17.
//  Copyright © 2017 waylens. All rights reserved.
//
import WaylensCarlos
import WaylensPiedPiper
import Alamofire

extension Dictionary: ExpensiveObject {
    /// The number of characters of the string
    public var cost: Int {
        return self.keys.count
    }
}

struct WLAPIRequest: StringConvertible {
    let params: [String: Any]
    let endPoint: EndPoint
    func toString() -> String {
        var components: [(String, String)] = []
        let encoding = URLEncoding()
        for key in params.keys.sorted(by: <) {
            let value = params[key]!
            components += encoding.queryComponents(fromKey: key, value: value)
        }
        return endPoint.url + "?" + components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

class WLAPIFetcher: Fetcher {
    typealias KeyType = WLAPIRequest
    typealias OutputType = [String:Any]
    func get(_ key: WLAPIRequest) -> Future<[String:Any]> {
        let promise = Promise<[String:Any]>()
        let dataRequest = WaylensClientS.shared.get(key.endPoint, params: key.params) { (result) in
            if result.isSuccess {
                promise.succeed(result.value!)
            } else {
                promise.fail(result.error!)
            }
        }
        promise.onCancel {
            dataRequest.cancel()
        }
        return promise.future
    }
}
