//
//  SetupSuccessRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SetupSuccessRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: SetupSuccessIxResponder?

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        if let button = tableView.tableHeaderView as? UIButton {
            button.setTitleColor(UIColor.semanticColor(.label(.secondary)), for: .normal)
            button.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
        }
    }
}

//MARK: - Private

private extension SetupSuccessRootView {

    func setup() {
        let doneIconButton = UIButton(type: .custom)
        doneIconButton.frame.size = CGSize(width: 300.0, height: 150.0)
        doneIconButton.isUserInteractionEnabled = false
        doneIconButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        doneIconButton.set(image: #imageLiteral(resourceName: "icon_done"), title: NSLocalizedString("Setup Successfully!", comment: "Setup Successfully!"), titlePosition: .bottom, additionalSpacing: 14.0, state: .normal)

        tableView.tableHeaderView = doneIconButton

        let okButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("OK", comment: "OK"), color: UIColor.semanticColor(.tint(.primary)))
        okButton.addTarget(self, action: #selector(okButtonTapped(_:)), for: .touchUpInside)
        okButton.setBackgroundImage(with: UIColor.semanticColor(.background(.quaternary)), for: .disabled)
        addBottomItemView(okButton)

        applyTheme()
    }

    @objc func okButtonTapped(_ sender: Any) {
        ixResponder?.done()
    }

}

extension SetupSuccessRootView: SetupSuccessUserInterface {

    func render(newState: SetupSuccessViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
        }
        
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
