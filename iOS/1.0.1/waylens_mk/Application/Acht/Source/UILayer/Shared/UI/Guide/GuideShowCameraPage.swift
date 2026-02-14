//
//  GuideShowCameraPage.swift
//  Acht
//
//  Created by Chester Shen on 7/27/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowCameraPage: GuideBasicPage {
    var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let homeVC = AppViewControllerManager.homeVC, let preview = homeVC.cameraPreviews[homeVC.pageControl.currentPage].shadowOverlay else { return }
//        let center = preview.convert(CGPoint(x: preview.bounds.midX, y: preview.bounds.midY), to: homeVC.view.window)
//        let w = 290.0 / 265.0 * preview.bounds.width
//        let maskFrame = CGRect(x: center.x - 0.5 * w , y: center.y - 0.5 * w, width: w, height: w)
//        let path = UIBezierPath(ovalIn: maskFrame)
//        let maskLayer = CAShapeLayer()
//        path.append(UIBezierPath(rect: homeVC.view.window!.bounds))
//        maskLayer.fillRule = .evenOdd
//        maskLayer.path = path.cgPath
//        controller?.background.layer.mask = maskLayer
//        button = UIButton(frame: maskFrame)
//        view.addSubview(button)
//        button.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
//        actionButton.isHidden = true
//        showTapIndicator(point: CGPoint(x: button.frame.midX - 16, y: button.frame.maxY + 12))
//        showHalo(center: CGPoint(x: button.frame.midX, y: button.frame.maxY - 35))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTip(NSLocalizedString("Tap to view videos", comment: "Tap to view videos"), center: CGPoint(x: button.frame.midX, y: button.frame.maxY + 60))
    }

}
