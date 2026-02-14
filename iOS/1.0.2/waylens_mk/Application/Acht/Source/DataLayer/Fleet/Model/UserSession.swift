//
//  UserSession.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class UserSession: Codable {

    // MARK: - Properties
    public let profile: UserProfile
    public let remoteSession: RemoteUserSession

    // MARK: - Methods
    public init(profile: UserProfile, remoteSession: RemoteUserSession) {
        self.profile = profile
        self.remoteSession = remoteSession
    }
}

extension UserSession: Equatable {

    public static func ==(lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.profile == rhs.profile &&
            lhs.remoteSession == rhs.remoteSession
    }
}
