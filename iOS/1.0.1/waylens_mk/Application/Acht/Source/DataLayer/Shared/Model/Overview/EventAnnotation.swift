//
//  EventAnnotation.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class EventAnnotation: MKPointAnnotation {

    private(set) var event: Event? = nil

    init(event: Event) {
        self.event = event
    }
    
}
