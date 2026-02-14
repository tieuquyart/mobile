//
//  RemoteUserSession.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public typealias AuthToken = String

public struct RemoteUserSession: Codable, Equatable {

    // MARK: - Properties
    let token: AuthToken

    // MARK: - Methods
    public init(token: AuthToken) {
        self.token = token
    }
}

