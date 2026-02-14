//
//  VehicleRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class VehicleRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: VehicleIxResponder?

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension VehicleRootView {

    @objc func removeButtonTapped(_ sender: Any) {
        ixResponder?.removeThisVehicle()
    }

    @objc func unbindButtonTapped(_ sender: Any) {
        ixResponder?.unbindCamera()
    }


}

extension VehicleRootView: VehicleUserInterface {

    func clearsSelection() {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    func render(newState: VehicleViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            switch indexPath.row {
            case 1:
                self?.ixResponder?.showDriverSelectionViewController()
            case 2:
                self?.ixResponder?.showModelEditViewController()
            case 3:
                if newState.vehicleProfile?.cameraSn.isEmpty == true {
                    self?.ixResponder?.showCameraBindingViewController()
                } else {
                    self?.ixResponder?.showCameraDetailViewController()
                }
            default:
                break
            }
        }

        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
        tableView.reloadData()

        removeAllBottomItemViews()

        if let vehicleProfile = newState.vehicleProfile {
            if vehicleProfile.cameraSn.isEmpty {
                let removeButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Remove", comment: "Remove"), color: UIColor.semanticColor(.background(.tertiary)))
                removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(removeButton)
            } else {
                let removeButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Unbind", comment: "Unbind"), color: UIColor.semanticColor(.background(.tertiary)))
                removeButton.addTarget(self, action: #selector(unbindButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(removeButton)
            }
        }

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

