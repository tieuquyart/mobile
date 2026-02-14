//
//  GuideShowViewModePage.swift
//  Acht
//
//  Created by Chester Shen on 7/27/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowViewModePage: GuideBasicPage {
    weak var detailVC: HNCameraDetailViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? PassThroughView)?.hitDelegate = self
        actionButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let panel = detailVC?.playerPanel, let viewModeButton = panel.controlView.viewModeButton else {
            return
        }
        let point = viewModeButton.superview!.convert(viewModeButton.center, to: view)
        showHalo(center: point)
        showTapIndicator(point: CGPoint(x: point.x - 16, y: point.y + 30))
        showTip(NSLocalizedString("Tap to switch from split screen to immsersive view", comment: "Tap to switch from split screen to immsersive view"), center: CGPoint(x: point.x, y: point.y + 78))
    }
    
    override func viewDidLayoutSubviews() {
        refreshMask()
    }
    
    func refreshMask() {
        guard let panelView = detailVC?.playerPanel.view else { return }
        if detailVC!.playerPanel.fullScreen {
            controller?.background.alpha = 0
        } else {
            let maskLayer = CAShapeLayer()
            let passFrame = panelView.convert(panelView.bounds, to: view)
            let path = UIBezierPath(rect: view.bounds)
            path.append(UIBezierPath(rect: passFrame))
            maskLayer.fillRule = .evenOdd
            maskLayer.path = path.cgPath
            controller?.background.layer.mask = maskLayer
            controller?.background.alpha = 1
        }
    }
}

extension GuideShowViewModePage: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        guard let panel = detailVC?.playerPanel else { return false }
        let passFrame = panel.view.convert(panel.view.bounds, to: view)
        return passFrame.contains(point)
    }
}
