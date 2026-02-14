//
//  CameraListRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraListRootView: ViewContainTableViewAndBottomButton, WLStatefulView {

    weak var ixResponder: CameraListIxResponder?

    override init() {
        super.init()

        let addButton = ButtonFactory.makeBigBottomButton(
            NSLocalizedString("+ Add New Camera", comment: "+ Add New Camera"),
            titleColor: UIColor.semanticColor(.tint(.primary)),
            color: UIColor.clear,
            borderColor: UIColor.semanticColor(.tint(.primary))
        )
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        addBottomItemView(addButton)

        setupStatefulView()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let newLayoutMargins = appDelegate.window?.rootViewController?.view.layoutMargins {
            layoutMargins = UIEdgeInsets(top: 0.0, left: newLayoutMargins.left, bottom: newLayoutMargins.bottom, right: newLayoutMargins.right)
        }
    }
}

//MARK: - Private

private extension CameraListRootView {

    @objc func addButtonTapped(_ sender: Any) {
        ixResponder?.addNewCamera()
    }

}

extension CameraListRootView: CameraListUserInterface {

    func render(newState: CameraListViewControllerState) {
        newState.dataSource.tableItemSelectionHandler = { [weak self] indexPath in
            self?.ixResponder?.selectCamera(at: indexPath.row)
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
        }
    }

}

