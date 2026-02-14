//
//  MaintenanceViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public struct MaintenanceViewControllerState: ReSwift.StateType, Equatable {
    public var hasDmsCamera: Bool = false
    public var obdWorkModeConfig: WLObdWorkModeConfig? = nil
    public var adasConfig: WLAdasConfig? = nil

    public var sections: [TableViewSection] {
        var sections = [
            TableViewSection(
                items: [
                    TableViewRow(
                        image: #imageLiteral(resourceName: "network"),
                        title: NSLocalizedString("Network", comment: "Network"),
                        detailViewControllerClass: NetworkDiagnosisViewController.self
                    ),
                    TableViewRow(
                        image: #imageLiteral(resourceName: "power cord"),
                        title: NSLocalizedString("Power Cord", comment: "Power Cord"),
                        detailViewControllerClass: PCTCableTypeViewController.self
                    )
                ],
                headerHeight: 0.001
            ),
            TableViewSection(
                items: [
                    TableViewRow(
                        image: #imageLiteral(resourceName: "SD card"),
                        title: NSLocalizedString("SD Card", comment: "SD Card"),
                        detailViewControllerClass: HNCSSDCardViewController.self
                    ),
                    TableViewRow(
                        image: #imageLiteral(resourceName: "APN"),
                        title: NSLocalizedString("APN Setting", comment: "APN Setting"),
                        detailViewControllerClass: UIAlertController.self
                    ),
                    TableViewRow(
                        image: #imageLiteral(resourceName: "PowerInfo"),
                        title: NSLocalizedString("Vehicle Power Information", comment: "Vehicle Power Information"),
                        detailViewControllerClass: PowerInfoViewController.self
                    )
                ]
            ),
            TableViewSection(
                items: [
                    TableViewRow(
                        image: #imageLiteral(resourceName: "report"),
                        title: NSLocalizedString("Report an Issue", comment: "Report an Issue"),
                        detailViewControllerClass: FeedbackController.self
                    ),
                    TableViewRow(
                        image: #imageLiteral(resourceName: "FAQ"),
                        title: NSLocalizedString("FAQ", comment: "FAQ"),
                        detailViewControllerClass: SafariViewController.self
                    ),
                    TableViewRow(
                        image: #imageLiteral(resourceName: "about"),
                        title: NSLocalizedString("About", comment: "About"),
                        detailViewControllerClass: AboutViewController.self
                    ),
                ]
            )
        ]

        var dynamicSectionItems: [TableViewRow] = []

        if hasDmsCamera {
            dynamicSectionItems.append(
                TableViewRow(
                    image: #imageLiteral(resourceName: "calib"),
                    title: NSLocalizedString("Calib the Driving Facing Camera", comment: "Calib the Driving Facing Camera"),
                    detailViewControllerClass: CalibrationInstallationPositionViewController.self
                )
            )
        }

        if let obdWorkMode = obdWorkModeConfig?.mode, AccountControlManager.shared.isLogin {
            dynamicSectionItems.append(
                TableViewRow(
                    image: #imageLiteral(resourceName: "ObdWorkModeSetting"),
                    title: NSLocalizedString("OBD Work Mode", comment: "OBD Work Mode"),
                    detail: NSLocalizedString(obdWorkMode.name, comment: ""),
                    detailViewControllerClass: ObdWorkModeViewController.self
                )
            )
        }
        
        if let _ = adasConfig {
            dynamicSectionItems.append(
                TableViewRow(
                    image: #imageLiteral(resourceName: "AdasSetting"),
                    title: NSLocalizedString("ADAS Settings", comment: "ADAS Settings"),
                    detailViewControllerClass: AdasConfigViewController.self
                )
            )
        }

        if !dynamicSectionItems.isEmpty {
            sections.insert(TableViewSection(items: dynamicSectionItems), at: 1)
        }

        if UserSetting.shared.debugEnabled {
            sections.append(TableViewSection(items: [
                TableViewRow(
                    image: #imageLiteral(resourceName: "Profile_setting"),
                    title: NSLocalizedString("Debug Options", comment: "Debug Options"),
                    detailViewControllerClass: DebugOptionViewController.self
                )
            ]))
        }

        return sections
    }

    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: MaintenanceViewState = MaintenanceViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct MaintenanceViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
