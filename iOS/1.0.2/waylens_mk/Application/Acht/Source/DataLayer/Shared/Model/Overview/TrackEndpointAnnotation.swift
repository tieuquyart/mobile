//
//  TrackEndpointAnnotation.swift
//  Fleet
//
//  Created by forkon on 2019/10/8.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class TrackEndpointAnnotation: MKPointAnnotation {

    enum TrackEndpointAnnotationType {
        case begin
        case end
    }

    private(set) var type: TrackEndpointAnnotationType
    private(set) var track: Track? = nil
    private(set) var isFinish: Bool

    init(track: Track, type: TrackEndpointAnnotationType, isFinish: Bool) {
        self.track = track
        self.type = type
        self.isFinish = isFinish
    }

}
