//
//  TimelineItem.swift
//  Acht
//
//  Created by forkon on 2019/10/15.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class TimelineCardItem {

    public typealias TextElementColorGenerator = () -> UIColor

    public struct TextElement {
        var text: String
        var font: UIFont
        var color: TextElementColorGenerator

        init(text: String, font: UIFont, color: @escaping TextElementColorGenerator) {
            self.text = text
            self.font = font
            self.color = color
        }

        init(text: String, font: UIFont) {
            self.text = text
            self.font = font
            self.color = { UIColor.black }
        }
    }

    private(set) var textElements: [TextElement] = []
    private(set) var date: Date
    private(set) var hasDetails: Bool = false

    var object: Any? = nil

    public init(textElements: [TextElement], date: Date, hasDetails: Bool) {
        self.textElements = textElements
        self.date = date
        self.hasDetails = hasDetails
    }

}

extension TimelineCardItem {

    public convenience init(timelineEvent: DriverTimelineEvent) {
        var textElements: [TimelineCardItem.TextElement] = []
        var hasDetails: Bool = false

        switch timelineEvent.type {
        case .cameraEvent:
            let content = (timelineEvent.content as! DriverTimelineCameraEventContent)

            textElements = [
                TimelineCardItem.TextElement.titleElement(content.eventType.description),
                TimelineCardItem.TextElement.abstractElement(content.address)
            ]
            hasDetails = true
        case .ignitionStatus:
            let content = (timelineEvent.content as! DriverTimelineIgnitionStatusContent)

            textElements = [
                TimelineCardItem.TextElement.titleElement(content.ignitionStatus.description)
            ]
        case .geoFence:
            let content = (timelineEvent.content as! DriverTimelineGeoFenceEventContent)

            var action = ""

            if content.geoFenceTriggerType.contains(.enter) {
                action = NSLocalizedString("Entered", comment: "Entered")
            }
            else if content.geoFenceTriggerType.contains(.exit) {
                action = NSLocalizedString("Exited", comment: "Exited")
            }

            let text = String(format: NSLocalizedString("%@ geo-fence %@", comment: "%@ geo-fence %@"), action, content.geoFenceRuleName)

            textElements = [
                TimelineCardItem.TextElement.titleElement(text)
            ]
        }

        self.init(textElements: textElements, date: timelineEvent.time, hasDetails: hasDetails)

        self.object = timelineEvent
    }
}

extension TimelineCardItem.TextElement {

    static func titleElement(_ title: String) -> TimelineCardItem.TextElement {
        return TimelineCardItem.TextElement(text: title, font: UIFont(name: "BeVietnamPro-Regular", size: 14)!, color: { UIColor.black })
    }

    static func abstractElement(_ abstract: String) -> TimelineCardItem.TextElement {
        return TimelineCardItem.TextElement(text: abstract, font: UIFont(name: "BeVietnamPro-Regular", size: 14)!, color: { UIColor.black })
    }

}
