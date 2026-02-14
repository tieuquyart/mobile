//
//  CameraTypeSelectionRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

enum CameraType: CaseIterable, CustomStringConvertible {
    case secure360OrSecure4K
    case secureES

    var description: String {
        switch self {
        case .secure360OrSecure4K:
            return NSLocalizedString("Secure360 / Secure4K", comment: "Secure360 / Secure4K")
        case .secureES:
            return NSLocalizedString("SecureES", comment: "SecureES")
        }
    }

}

class CameraTypeSelectionRootView: FlowStepRootView<MenuContentView> {
    weak var ixResponder: CameraTypeSelectionIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = NSLocalizedString("Please select the camera type.", comment: "Please select the camera type.")
        progressLabel.text = ""
        actionButton.isHidden = true
    }

}

//MARK: - Private

private extension CameraTypeSelectionRootView {

}

extension CameraTypeSelectionRootView: CameraTypeSelectionUserInterface {

    func render(newState: CameraTypeSelectionViewControllerState) {
        contentView.itemViews = CameraType.allCases.map({ (cameraType) -> UIView in
            let itemView = MenuItemView()
            itemView.textLabel?.text = cameraType.description
            itemView.selectionHandler = {[weak self] in
                self?.ixResponder?.select(cameraType: cameraType)
            }
            return itemView
        })
    }

}
