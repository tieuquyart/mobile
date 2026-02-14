//
//  EventPinAnnotationView.swift
//  Fleet
//
//  Created by forkon on 2019/9/27.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class EventPinAnnotationView: MKAnnotationView {

    init(annotation: EventAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "Event")

        if let event = annotation.event {
            switch event.eventType {
            case .parkingMotion:
                image = UIImage(named: "parking_big_shadow")
            case .parkingHit:
                image = UIImage(named: "Bump_big_shadow")
            case .drivingHit:
                image = UIImage(named: "Bump_big_shadow")
            case .parkingHeavy:
                image = UIImage(named: "Impact_big_shadow")
            case .drivingHeavy:
                image = UIImage(named: "Impact_big_shadow")
            case .hardAccel, .harshAccel, .severeAccel, .forwardCollisionWarning:
                image = UIImage(named: "Hard accel_big_shadow")
            case .hardBrake, .harshBrake, .severeBrake:
                image = UIImage(named: "Hard brake_big_shadow")
            case .sharpTurn, .harshTurn, .severeTurn:
                image = UIImage(named: "Sharp turn_big_shadow")
            case .driving:
                image = UIImage(named: "driving_big_shadow")
            default:
                if event.eventType!.isDMS || event.eventType!.isADAS {
                    image = UIImage(named: "DmsEvent")
                }
                else {
                    image = UIImage(named: "parking_big_shadow")
                }
            }
            //thiếu vượt quá tốc độ
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
