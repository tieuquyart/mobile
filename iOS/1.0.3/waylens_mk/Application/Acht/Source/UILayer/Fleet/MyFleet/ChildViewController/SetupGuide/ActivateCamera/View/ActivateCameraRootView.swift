//
//  ActivateCameraRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import Former

class ActivateCameraRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: ActivateCameraIxResponder?

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        if let label = tableView.tableHeaderView as? UILabel {
            label.textColor = UIColor.semanticColor(.label(.secondary))
            label.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
        }
    }
}

//MARK: - Private

private extension ActivateCameraRootView {

    func setup() {
        let nextButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.semanticColor(.tint(.primary)))
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        nextButton.setBackgroundImage(with: UIColor.semanticColor(.background(.quaternary)), for: .disabled)
        addBottomItemView(nextButton)
    }

    @objc func nextButtonTapped(_ sender: Any) {
        ixResponder?.nextStep()
    }

}

extension ActivateCameraRootView: ActivateCameraUserInterface {

    func render(newState: ActivateCameraViewControllerState) {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "BeVietnamPro-Medium", size: 20)!
        label.text = NSLocalizedString("Activate the SIM card of the camera!", comment: "Activate the SIM card of the camera!")
        label.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 150.0)

        tableView.tableHeaderView = label

        let footer = InstructionFooterView()
        footer.text = "ⓘ " + NSLocalizedString("When you activate the camera, we will immediately charge the camera for the service fee and the possible data fee depends on usage.", comment: "When you activate the camera, we will immediately charge the camera for the service fee and the possible data fee depends on usage.")

        footer.resize(withWidth: UIScreen.main.bounds.width)

        tableView.tableFooterView = footer

        applyTheme()

        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
        tableView.reloadData()

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

