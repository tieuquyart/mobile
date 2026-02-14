//
//  MapActionCoordination.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol MapActionCoordination: AnyObject {
    func viewController(_ viewController: UIViewController, showDetailOf driver: Driver)
    func viewController(_ viewController: UIViewController, showDetailOf event: Event)
    func viewController(_ viewController: UIViewController, dropPinsForVehicles vehicles: [Vehicle])
    func viewController(_ viewController: UIViewController, dropPinsForEvents events: [Event])
    func viewController(_ viewController: UIViewController, drawTrackFor trip: Trip)
    func viewController(_ viewController: UIViewController, drawTracksFor trips: [Trip])
    func viewController(_ viewController: UIViewController, removeTrackFor trip: Trip)
    func viewControllerWillPresent(_ viewController: UIViewController)
//    func viewControllerDidPresent(_ viewController: UIViewController)
}
