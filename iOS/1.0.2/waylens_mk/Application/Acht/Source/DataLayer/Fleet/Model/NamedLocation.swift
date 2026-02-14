//
//  NamedLocation.swift
//  Fleet
//
//  Created by forkon on 2020/5/28.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

public struct NamedLocation: Equatable {
  // MARK: - Properties
  public internal(set) var name: String
  public internal(set) var location: CLLocation

  // MARK: - Methods
  public init(name: String, location: CLLocation) {
    self.name = name
    self.location = location
  }
}
