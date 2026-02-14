//
//  AlertSettingsRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import Former

class AlertSettingsRootView: ViewContainTableViewAndBottomButton, WLStatefulView {

    weak var ixResponder: AlertSettingsIxResponder?

    private lazy var former = Former(tableView: tableView)

    private let driverReturnTheVehicleRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Driver return the vehicle", comment: "Driver return the vehicle")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { (isOn) in

    }

    private lazy var driversDrivingOrParkingRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Drivers driving or parking", comment: "Drivers driving or parking")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { [weak self](isOn) in
            self?.ixResponder?.toggle(setting: AlertSettings.drivingOrParking, isOn: isOn)
    }

    private lazy var geoFenceRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Drivers enter or exit geo-fence", comment: "Drivers enter or exit geo-fence")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { [weak self] (isOn) in
            self?.ixResponder?.toggle(setting: AlertSettings.geoFencingTypeEvents, isOn: isOn)
    }

    private let orderRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Drivers confirm/start/arrive orders", comment: "Drivers confirm/start/arrive orders")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { (isOn) in

    }

    private lazy var behaviorRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Behavior type events", comment: "Behavior type events")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { [weak self] (isOn) in
            self?.ixResponder?.toggle(setting: AlertSettings.behaviorTypeEvents, isOn: isOn)
    }

    private lazy var hitRow = SwitchRowFormer<FormSwitchCell>(instantiateType: .Class) { (cell) in
        cell.titleLabel.text = NSLocalizedString("Hit type events", comment: "Hit type events")
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        .configure(handler: { (rowFormer) in
            rowFormer.rowHeight = 60.0
        })
        .onSwitchChanged { [weak self] (isOn) in
            self?.ixResponder?.toggle(setting: AlertSettings.hitTypeEvents, isOn: isOn)
    }

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlertSettingsRootView: AlertSettingsUserInterface {

    func render(newState: AlertSettingsViewControllerState) {
        hasFinishedFirstLoading = newState.hasFinishedFirstLoading
        if hasFinishedFirstLoading && lastState == .loading {
            endLoading()
        }

        driversDrivingOrParkingRow.switched = newState.isDrivingOrParkingAlertEnabled
        behaviorRow.switched = newState.isBehaviorTypeEventsAlertEnabled
        hitRow.switched = newState.isHitTypeEventsAlertEnabled
        geoFenceRow.switched = newState.isGeoFencingTypeEventsAlertEnabled

        former.reload()

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                HNMessage.showSuccess(message: activityIndicatingState.message)
                HNMessage.dismiss(withDelay: 1.0)
            } else {
                HNMessage.show(message: activityIndicatingState.message)
            }
        }
    }

}

//MARK: - Private

private extension AlertSettingsRootView {

    func setup() {
        setupStatefulView()
        startLoading()

        let alertReceiveSectionHeader = LabelViewFormer<FormLabelHeaderView>() { view in
            view.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
            view.contentView.backgroundColor = UIColor.clear
            }.configure { [weak self] (viewFormer) in
                guard let self = self else {
                    return
                }

                viewFormer.text = NSLocalizedString("Please select the type of alert you would like to receive", comment: "Please select the type of alert you would like to receive")
                viewFormer.viewHeight = self.calucalteHeaderHeight(for: viewFormer)
        }

        let footer = LabelViewFormer<FormLabelHeaderView>().configure { (viewFormer) in
            viewFormer.viewHeight = 1.0
        }

        let alertReceiveSection = SectionFormer(rowFormer: /*driverReturnTheVehicleRow,*/ driversDrivingOrParkingRow, geoFenceRow/*, orderRow*/)
            .set(headerViewFormer: alertReceiveSectionHeader)
            .set(footerViewFormer: footer)

        former.append(sectionFormer: alertReceiveSection)

        let videoEventSectionHeader = LabelViewFormer<FormLabelHeaderView>() { view in
            view.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
            view.contentView.backgroundColor = UIColor.clear
            }
            .configure { (viewFormer) in
                viewFormer.text = NSLocalizedString("Video Events", comment: "Video Events")
                viewFormer.viewHeight = self.calucalteHeaderHeight(for: viewFormer)
        }

        let videoEventSection = SectionFormer(rowFormer: behaviorRow, hitRow)
            .set(headerViewFormer: videoEventSectionHeader)

        former.append(sectionFormer: videoEventSection)
    }

    func calucalteHeaderHeight(for labelViewFormer: LabelViewFormer<FormLabelHeaderView>) -> CGFloat {
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: nil)
        headerView.frame.size.width = UIScreen.main.bounds.width
        headerView.textLabel?.text = labelViewFormer.text
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        if let textLabelHeight = headerView.textLabel?.frame.height {
            return textLabelHeight + 10.0
        } else {
            return Constants.UI.sectionHeaderHeight
        }
    }

}
