//
//  GeoFenceShape.swift
//  Fleet
//
//  Created by forkon on 2020/6/3.
//  Copyright © 2020 waylens. All rights reserved.
//

public enum GeoFenceShape: Equatable {
    case circle(center: CLLocationCoordinate2D, radius: CLLocationDistance)
    case polygon(points: [CLLocationCoordinate2D])
    case unknown
}

public enum GeoFenceShapeForEdit: Equatable {
    case circle(center: CLLocationCoordinate2D?, radius: CLLocationDistance?)
    case polygon(points: [CLLocationCoordinate2D]?)

    public init?(shape: GeoFenceShape?) {
        guard let shape = shape else {
            return nil
        }

        if case .circle(let center, let radius) = shape {
            self = .circle(center: center, radius: radius)
        }
        else if case .polygon(let points) = shape {
            self = .polygon(points: points)
        }
        else {
            return nil
        }
    }
}
