//
//  CameraDetailRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraDetailRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: CameraDetailIxResponder?
    private var dataSource: CameraDetailDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension CameraDetailRootView {

    func setup() {

    }

}

extension CameraDetailRootView: CameraDetailUserInterface {

    func render(newState: CameraDetailViewControllerState) {
        let firmwareToShow = newState.isShowingShortFirmwareVersion ? newState.cameraInfo?.firmwareShort : newState.cameraInfo?.firmware

        let items: [StandardTableViewCellViewModel] = [
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Vehicle", comment: "Vehicle"), detail: newState.cameraInfo?.vehiclePlateNumber),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Serial Number (S/N)", comment: "Serial Number (S/N)"), detail: newState.cameraInfo?.cameraSN),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Status", comment: "Status"), detail: newState.cameraInfo?.mode?.description),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Firmware Version", comment: "Firmware Version"), detail: firmwareToShow),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Data Usage", comment: "Data Usage"), detail: String.fromBytes((newState.cameraInfo?.dataUsageInKB ?? 0) * 1024, countStyle: .binary))
        ]

        let firmwareVersionRow = 3
        dataSource = CameraDetailDataSource(items: items, firmwareVersionRow: firmwareVersionRow)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            if indexPath.row == firmwareVersionRow {
                self?.ixResponder?.didTapFirmwareVersionRow()
            }
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
    }

}

