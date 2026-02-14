//
//  TrackEndpointAnnotationView.swift
//  Fleet
//
//  Created by forkon on 2019/10/8.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class TrackEndpointAnnotationView: MKAnnotationView {

    init(annotation: TrackEndpointAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "TrackEndpoint")

        switch annotation.type {
        case .begin:
            image = UIImage(named: annotation.isFinish ? "path_start_history" : "path_start")
        case .end:
            if annotation.isFinish {
                image = UIImage(named: "Circular point")
            } else {
                image = UIImage(named: "driving_big_shadow")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
 
