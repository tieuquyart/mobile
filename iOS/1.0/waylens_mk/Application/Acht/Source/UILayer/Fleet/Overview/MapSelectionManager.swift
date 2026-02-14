//
//  MapSelectionManager.swift
//  Fleet
//
//  Created by forkon on 2019/9/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class MapSelectionManager {

    private var mapView: MKMapView? = nil

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

    }
    
}
