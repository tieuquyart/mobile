//
//  Convertable.swift
//  Acht
//
//  Created by TranHoangThanh on 1/10/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
/// define protocol convert Struct or Class to Dictionary
///
protocol Convertable: Codable {

}

extension Convertable {

    /// implement convert Struct or Class to Dictionary
    func convertToDict() -> Dictionary<String, Any> {
    
        var dict: Dictionary<String, Any> = [:]

        do {
            print("init model")
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            
            print("struct convert to data")

            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> ?? [:]

        } catch {
            print(error)
        }

        return dict
    }
}
