//
//  LocationRepository.swift
//  Fleet
//
//  Created by forkon on 2020/5/28.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation
import PromiseKit

public protocol LocationRepository {
  func searchForLocations(using query: String) -> Promise<[NamedLocation]>
}
