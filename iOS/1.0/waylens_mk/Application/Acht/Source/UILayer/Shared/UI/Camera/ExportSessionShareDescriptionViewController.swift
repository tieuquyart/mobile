//
//  ExportSessionShareDescriptionViewController.swift
//  Acht
//
//  Created by forkon on 2019/5/6.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ExportSessionShareDescriptionViewController: UIViewController {

    @IBOutlet private weak var agreementButton: UIButton!
    @IBOutlet private weak var agreementLabel: LinkLabel!

    var acceptedAgreement: Bool {
        return agreementButton.isSelected
    }

    var acceptanceStateChangeHandler: ((Bool) -> ())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        agreementLabel.setLink(for: NSLocalizedString("Waylens Agreement", comment: "Waylens Agreement")) { [unowned self] in
            self.showSharingVideoAgreementViewController()
        }
    }

    func addToParent(_ parentViewController: UIViewController, containingView: UIView) {
        willMove(toParent: parentViewController)
        parentViewController.addChild(self)
        view.frame = containingView.bounds
        containingView.addSubview(view)
        didMove(toParent: parentViewController)
    }

    override func removeFromParent() {
        super.removeFromParent()

        view.removeFromSuperview()
    }

    @IBAction func agreementButtonTapped(_ sender: Any) {
        agreementButton.isSelected = !agreementButton.isSelected

        acceptanceStateChangeHandler?(acceptedAgreement)
    }

}
