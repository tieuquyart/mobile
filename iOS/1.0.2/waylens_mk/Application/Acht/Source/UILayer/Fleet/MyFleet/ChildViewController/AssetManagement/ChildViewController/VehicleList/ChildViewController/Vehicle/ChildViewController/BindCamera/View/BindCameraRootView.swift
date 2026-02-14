//
//  BindCameraRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BindCameraRootView: ViewContainTableViewAndBottomButton, WLStatefulView {
    weak var ixResponder: BindCameraIxResponder?

    override init() {
        super.init()

        tableView.tableHeaderView = LabelHeaderView(title: NSLocalizedString("Please choose a camera Serial Number (S/N)", comment: "Please choose a camera Serial Number (S/N)"))

        applyTheme()

        setupStatefulView()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        tableView.tableHeaderView?.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))
    }
}

//MARK: - Private

private extension BindCameraRootView {

}

extension BindCameraRootView: BindCameraUserInterface {

    func render(newState: BindCameraViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.select(indexPath: indexPath)
        }

        tableView.dataSource = newState.dataSource
        tableView.delegate = newState.dataSource
        tableView.reloadData()

        hasFinishedFirstLoading = newState.hasFinishedFirstLoading
        if hasFinishedFirstLoading && lastState == .loading {
            endLoading()
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                HNMessage.showSuccess(message: activityIndicatingState.message)
                HNMessage.dismiss(withDelay: 1.0)
            } else {
                if hasFinishedFirstLoading {
                    HNMessage.show(message: activityIndicatingState.message)
                }
            }
        }
    }

}
