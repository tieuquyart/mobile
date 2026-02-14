//
//  Track.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

class Track {
    weak var owner: Trip?
    private(set) var coordinates: [CLLocationCoordinate2D] = []
    init(owner: Trip, coordinates: [CLLocationCoordinate2D]) {
        self.owner = owner
        self.coordinates = coordinates
    }
}
extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.owner?.tripId == rhs.owner?.tripId && lhs.coordinates == rhs.coordinates
    }

}
