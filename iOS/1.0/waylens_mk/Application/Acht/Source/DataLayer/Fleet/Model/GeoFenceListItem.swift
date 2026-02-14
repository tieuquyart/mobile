//
//  GeoFenceListItem.swift
//  Fleet
//
//  Created by forkon on 2020/6/3.
//  Copyright © 2020 waylens. All rights reserved.
//

import DifferenceKit

public enum GeoFenceListType: String, Equatable {
    case all
    case unbind
    case bind
}

public struct GeoFenceListItem: Decodable, Equatable {
    let fenceID: GeoFenceId
    let name: String
    let enabled: Bool
    let address: String
    let description: String
    let createTime: Date
    let fenceRuleList: [GeoFenceRule]
    var shape: GeoFenceShape

    private enum CodingKeys: String, CodingKey {
        case fenceID
        case name
        case enabled
        case address
        case description
        case createTime
        case fenceRuleList
        case center
        case radius
        case polygon
    }

    private enum AddressCodingKeys: String, CodingKey {
        case address
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        fenceID = try values.decode(String.self, forKey: .fenceID)
        name = (try? values.decode(String.self, forKey: .name)) ?? ""
        enabled = (try? values.decode(Bool.self, forKey: .enabled)) ?? false
        description = (try? values.decode(String.self, forKey: .description)) ?? ""
        createTime = Date(millisecondsSince1970: try values.decode(TimeInterval.self, forKey: .createTime))
        fenceRuleList = (try? values.decode([GeoFenceRule].self, forKey: .fenceRuleList)) ?? []

        let nestedContainer = try values.nestedContainer(keyedBy: AddressCodingKeys.self, forKey: .address)
        address = (try? nestedContainer.decode(String.self, forKey: .address)) ?? ""

        if values.contains(.center) && values.contains(.radius) {
            do {
                guard let centerDegrees: [CLLocationDegrees] = try? values.decode([CLLocationDegrees].self, forKey: .center), centerDegrees.count >= 2 else {
                    shape = .unknown
                    return
                }

                let center = CLLocationCoordinate2D(latitude: centerDegrees[0], longitude: centerDegrees[1]).correctedForChina()

                guard let radius = try? values.decode(CLLocationDistance.self, forKey: .radius) else {
                    shape = .unknown
                    return
                }

                shape = .circle(center: center, radius: radius)
            }
        }
        else if values.contains(.polygon) {
            do {
                guard let polygonRaw: [[CLLocationDegrees]] = try? values.decode([[CLLocationDegrees]].self, forKey: .polygon) else {
                    shape = .unknown
                    return
                }

                let coordinates: [CLLocationCoordinate2D] = polygonRaw.compactMap{ degrees in
                    if degrees.count >= 2 {
                        return CLLocationCoordinate2D(latitude: degrees[0], longitude: degrees[1]).correctedForChina()
                    }
                    else {
                        return nil
                    }
                }

                shape = .polygon(points: coordinates)
            }
        }
        else {
            shape = .unknown
        }
    }
}

extension GeoFenceListItem: Differentiable {

    public var differenceIdentifier: String {
        return fenceID
    }

}
