//
//  EventTypeFilter.swift
//  Fleet
//
//  Created by forkon on 2019/12/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class EventTypeFilter: DataFilter {
    private let typeFilters: [TypeFilter]

    init(typeFilters: [TypeFilter]) {
        self.typeFilters = typeFilters
    }

    func match(_ dataModel: Any) -> Bool {
        var match = false

        if typeFilters.isEmpty {
            match = true
        } else {
            let mirror: Mirror

            if let timelineCardItem = dataModel as? TimelineCardItem, let object = timelineCardItem.object {
                mirror = Mirror(reflecting: object)
            } else {
                mirror = Mirror(reflecting: dataModel)
            }

            if let content = mirror.children.first(where: {$0.label == "content"})?.value {
                typeFilters.forEach { (typeFilter) in
                    switch typeFilter {
                    case .drivingParking:
                        if content is DriverTimelineIgnitionStatusContent {
                            match = true
                        }
                    case .behaviorTypeEvents:
                        if let content = content as? DriverTimelineCameraEventContent, HNVideoOptions.fromType(content.eventType) == .behavior {
                            match = true
                        }
                    case .hitTypeEvents:
                        if let content = content as? DriverTimelineCameraEventContent, (HNVideoOptions.fromType(content.eventType) == .hit || HNVideoOptions.fromType(content.eventType) == .heavy) {
                            match = true
                        }
                    case .geoFencing:
                        if content is DriverTimelineGeoFenceEventContent {
                            match = true
                        }
                    }
                }
            }
        }

        return match
    }
}
