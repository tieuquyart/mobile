//
//  MapFloatingPanelController.swift
//  Acht
//
//  Created by forkon on 2019/9/23.
//  Copyright © 2019 Maxim Bilan. All rights reserved.
//

import UIKit
import FloatingPanel

class MapFloatingPanelController: FloatingPanelController {

    private var animationDuration: TimeInterval = 0.25

    weak var floatingPanelLayout: FloatingPanelLayout? = nil
    weak var actionCoordinator: MapActionCoordinator? = nil

    deinit {
        debugPrint("\(self) deinit")
        set(contentViewController: nil)
    }

    init() {
        super.init(delegate: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        delegate = self
        surfaceView.grabberHandle.barColor = .clear
        surfaceView.backgroundColor = .clear
        surfaceView.cornerRadius = 0.0
        surfaceView.shadowHidden = false
       // surfaceView.grabberHandle.barColor = UIColor.semanticColor(.grabberHandleBar)
        surfaceView.grabberHandleWidth = 40.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        (contentViewController as? MapFloatingSubPanelController)?.delegate = actionCoordinator
    }

    func setInitialSubPanel(_ subPanel: MapFloatingSubPanelController) {
        floatingPanelLayout = subPanel.floatingPanelLayout
        set(contentViewController: subPanel)
    }

    func presentSubPanel(_ subPanel: MapFloatingSubPanelController) {
        floatingPanelLayout = subPanel.floatingPanelLayout

        UIView.animate(withDuration: animationDuration) { [unowned self] in
            self.toggleGrabberHandleDisplay()
            self.updateLayout()
        }
        subPanel.delegate = actionCoordinator
        lastSubPanel?.viewWillDisappear(true)
        lastSubPanel?.present(subPanel, animated: true, completion: {

        })

        actionCoordinator?.updateNavigationBar()
        actionCoordinator?.updateMapViewLayoutMargins()

        if let floatingPanelLayout = floatingPanelLayout {
            move(to: floatingPanelLayout.initialPosition, animated: true)
        }
    }

    func popLastSubPanel() {
        guard canPopSubPanel, let lastSubPanel = lastSubPanel else { return }

        floatingPanelLayout = lastSubPanel.previousSubPanel?.floatingPanelLayout

        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.toggleGrabberHandleDisplay()
            self?.updateLayout()
        }
        lastSubPanel.viewWillDisappear(true)
        lastSubPanel.delegate = nil
        lastSubPanel.previousSubPanel?.viewWillAppear(true)
        lastSubPanel.dismiss(animated: true, completion: { [weak self] in
            self?.actionCoordinator?.updateNavigationBar()
            self?.actionCoordinator?.updateMapViewLayoutMargins()
        })

        if let previousSubPanelPosition = lastSubPanel.previousSubPanel?.position {
            move(to: previousSubPanelPosition, animated: true)
        }
    }

}

extension MapFloatingPanelController: FloatingPanelControllerDelegate {

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return floatingPanelLayout
    }

    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        lastSubPanel?.position = position
    }

}

extension MapFloatingPanelController {

    var lastSubPanel: MapFloatingSubPanelController? {
        var retval = contentViewController

        while retval?.presentedViewController != nil {
            retval = retval?.presentedViewController
        }

        return retval as? MapFloatingSubPanelController
    }

    var canPopSubPanel: Bool {
        if lastSubPanel == contentViewController {
            return false
        } else {
            return true
        }
    }
}

extension MapFloatingPanelController {

    private func toggleGrabberHandleDisplay() {
        if let supportedPositionsCount = self.floatingPanelLayout?.supportedPositions.count, supportedPositionsCount > 1 {
            self.surfaceView.grabberHandle.isHidden = false
        } else {
            self.surfaceView.grabberHandle.isHidden = true
        }
    }

}
