//
//  VehiclePinAnnotationView.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class VehiclePinAnnotationView: MKAnnotationView {

    init(annotation: VehicleAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "Vehicle")

        if let vehicle = annotation.vehicle {
            switch vehicle.state {
            case .driving:
                image = UIImage(named: "driving_big_shadow")
            case .parking:
                image = UIImage(named: "parking_big_shadow")
            case .offline:
                image = UIImage(named: "offline_big_shadow")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

extension VehiclePinAnnotationView {

    private func setup() {

    }

}
