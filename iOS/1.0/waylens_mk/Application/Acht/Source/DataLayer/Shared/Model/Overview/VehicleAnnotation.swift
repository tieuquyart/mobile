//
//  VehicleAnnotation.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class VehicleAnnotation: MKPointAnnotation {

    private(set) var vehicle: Vehicle? = nil

    init(vehicle: Vehicle) {
        super.init()

        self.vehicle = vehicle
    }

}
