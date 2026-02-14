//
//  WLAPIResult.swift
//  Acht
//
//  Created by Chester Shen on 8/3/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
enum WLAPIResult {
    case success([String: Any])
    case failure(WLError?)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: [String: Any]? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: WLError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            if let msg = error?.asAPIError?.message {
                var err = error
                err?.msg = msg
                return err
            }
            return error
        }
    }
}
