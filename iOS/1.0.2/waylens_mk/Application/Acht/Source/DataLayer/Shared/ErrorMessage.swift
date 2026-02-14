//
//  ErrorMessage.swift
//  Fleet
//
//  Created by forkon on 2019/11/8.
//  Copyright © 2019 waylens. All rights reserved.
//

public struct ErrorMessage: Error, Hashable {

    // MARK: - Properties
    public let id: UUID
    public let title: String
    public let message: String

    // MARK: - Methods
    public init(title: String, message: String) {
        self.id = UUID()
        self.title = title
        self.message = message
    }
}

