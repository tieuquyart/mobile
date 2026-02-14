//
//  CameraRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: CameraIxResponder?
    private var dataSource: CameraDataSource = CameraDataSource(items: [])

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension CameraRootView {

    @objc func setupButtonTapped(_ sender: Any) {
        ixResponder?.gotoSetup()
    }

    @objc func removeButtonTapped(_ sender: Any) {
        ixResponder?.removeCamera()
    }

    @objc func activateButtonTapped(_ sender: Any) {
        ixResponder?.activateCamera()
    }

}

extension CameraRootView: CameraUserInterface {

    func render(newState: CameraViewControllerState) {
        if let cameraProfile = newState.cameraProfile {
            dataSource = CameraDataSource(items:
                [
                    .cameraSN(cameraProfile.isBind ? String(format: NSLocalizedString("Bound by %@", comment: ""), cameraProfile.plateNumber) : NSLocalizedString("Not Bound", comment: "Not Bound")),
                    .model(cameraProfile.hardwareModel),
                    .firmwareVersion(newState.isShowingShortFirmwareVersion ? cameraProfile.firmwareShort : cameraProfile.firmware),
                    .mountModel(cameraProfile.mountModel ?? ""),
                    .mountVersion(cameraProfile.mountVersion ?? ""),
                    .iccid(cameraProfile.iccid)
                ]
            )
        } else {
            dataSource = CameraDataSource(items: [])
        }

        dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            if case .firmwareVersion = self?.dataSource.item(at: indexPath) {
                self?.ixResponder?.didTapFirmwareVersionRow()
            }
        }

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        removeAllBottomItemViews()

        if let cameraProfile = newState.cameraProfile {
            switch (cameraProfile.isBind, cameraProfile.simState) {
            case (false, .deactivated),
                 (false, .unknown):
                let setupButton = ButtonFactory.makeBigBottomButton(
                    NSLocalizedString("Go to Setup", comment: "Go to Setup"),
                    titleColor: UIColor.semanticColor(.tint(.primary)),
                    color: UIColor.clear,
                    borderColor: UIColor.semanticColor(.tint(.primary))
                )
                setupButton.addTarget(self, action: #selector(setupButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(setupButton)

                let removeButton = ButtonFactory.makeBigBottomButton(
                    NSLocalizedString("Remove", comment: "Remove"),
                    titleColor: UIColor.semanticColor(.label(.tertiary)),
                    color: UIColor.clear,
                    borderColor: UIColor.semanticColor(.fill(.tertiary))
                )
                removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(removeButton)
            case (false, .activated):
                let setupButton = ButtonFactory.makeBigBottomButton(
                    NSLocalizedString("Go to Setup", comment: "Go to Setup"),
                    titleColor: UIColor.semanticColor(.tint(.primary)),
                    color: UIColor.clear,
                    borderColor: UIColor.semanticColor(.tint(.primary))
                )
                setupButton.addTarget(self, action: #selector(setupButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(setupButton)

                let removeAndDeactivateButton = ButtonFactory.makeBigBottomButton(
                    NSLocalizedString("Remove and Deactivate", comment: "Remove and Deactivate"),
                    titleColor: UIColor.semanticColor(.label(.tertiary)),
                    color: UIColor.clear,
                    borderColor: UIColor.semanticColor(.fill(.tertiary))
                )
                removeAndDeactivateButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(removeAndDeactivateButton)
            case (true, .deactivated),
                 (true, .unknown):
                let activateButton = ButtonFactory.makeBigBottomButton(
                    NSLocalizedString("Activate", comment: "Activate"),
                    titleColor: UIColor.semanticColor(.tint(.primary)),
                    color: UIColor.clear,
                    borderColor: UIColor.semanticColor(.tint(.primary))
                )
                activateButton.addTarget(self, action: #selector(activateButtonTapped(_:)), for: .touchUpInside)
                addBottomItemView(activateButton)
            case (true, .activated):
                break
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

}

