//
//  FleetLocationRepository.swift
//  Fleet
//
//  Created by forkon on 2020/5/28.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation
import PromiseKit
import MapKit

class FleetLocationRepository: LocationRepository {

    private let geocoder: CLGeocoder = CLGeocoder()

    func searchForLocations(using query: String) -> Promise<[NamedLocation]> {
        return Promise<[NamedLocation]> { seal in
            geocoder.geocodeAddressString(query) { (placeMarks, error) in
                if let error = error {
                    seal.reject(error)
                    return
                }

                let namedLocations: [NamedLocation] = placeMarks?.compactMap{ placeMark in
                    if let name = placeMark.name, let location = placeMark.location {
                        return NamedLocation(name: name, location: location)
                    }
                    else {
                        return nil
                    }
                } ?? []

                seal.fulfill(namedLocations)
            }
        }
    }

}
