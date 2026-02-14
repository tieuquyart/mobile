//
//  NotificationListCell.swift
//  Fleet
//
//  Created by forkon on 2019/12/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class NotificationListCell: UITableViewCell {

    @IBOutlet private weak var driverAndEventLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var eventTypeColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(with driverTimelineEvent: DriverTimelineEvent?) {
        cleanUp()

        if let driverTimelineEvent = driverTimelineEvent {
            driverAndEventLabel.text = driverTimelineEvent.driverName

            if let cameraEventContent = driverTimelineEvent.content as? DriverTimelineCameraEventContent {
                let eventDescription = cameraEventContent.eventType.description
                if !eventDescription.isEmpty {
                    driverAndEventLabel.text? += " · " + eventDescription
                }

                addressLabel.text = cameraEventContent.address
                eventTypeColorView.backgroundColor = cameraEventContent.eventType.color
                eventTypeColorView.widthConstraint?.constant = 4.0
                eventTypeColorView.heightConstraint?.constant = 60.0

                accessoryType = .disclosureIndicator
            }
            else if let ignitionStatusContent = driverTimelineEvent.content as? DriverTimelineIgnitionStatusContent {
                addressLabel.text = ignitionStatusContent.ignitionStatus.description
                eventTypeColorView.backgroundColor = ignitionStatusContent.ignitionStatus.color
                eventTypeColorView.widthConstraint?.constant = 7.0
                eventTypeColorView.heightConstraint?.constant = 7.0

                accessoryType = .none
            }
            else if let geoFenceContent = driverTimelineEvent.content as? DriverTimelineGeoFenceEventContent {
                var action = ""

                if geoFenceContent.geoFenceTriggerType.contains(.enter) {
                    action = NSLocalizedString("Entered", comment: "Entered")
                }
                else if geoFenceContent.geoFenceTriggerType.contains(.exit) {
                    action = NSLocalizedString("Exited", comment: "Exited")
                }

                addressLabel.text = String(format: NSLocalizedString("%@ %@ driving %@", comment: "%@ %@ driving %@"), action, geoFenceContent.geoFenceRuleName, driverTimelineEvent.plateNumber)
                eventTypeColorView.backgroundColor = UIColor(rgb: 0x99A0A9)
                eventTypeColorView.widthConstraint?.constant = 7.0
                eventTypeColorView.heightConstraint?.constant = 7.0

                accessoryType = .none
            }

            timeLabel.text = driverTimelineEvent.time.dateManager.fleetDate.toStringUsingInNotificationList()

            eventTypeColorView.layer.cornerRadius = (eventTypeColorView.widthConstraint?.constant ?? 0.0) / 2
        }
    }
    
}

//MARK: - Priavte

private extension NotificationListCell {

    func setup() {
        driverAndEventLabel.lineBreakMode = .byTruncatingMiddle
        eventTypeColorView.layer.masksToBounds = true
    }

    func cleanUp() {
        driverAndEventLabel.text = nil
        timeLabel.text = nil
        addressLabel.text = nil
        eventTypeColorView.backgroundColor = UIColor(rgb: 0x99A0A9)
        eventTypeColorView.widthConstraint?.constant = 4.0
        eventTypeColorView.heightConstraint?.constant = 60.0
    }
}

extension NotificationListCell: NibCreatable {}
