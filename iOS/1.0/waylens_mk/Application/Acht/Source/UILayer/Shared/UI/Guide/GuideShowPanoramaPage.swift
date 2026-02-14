//
//  GuideShowPanoramaPage.swift
//  Acht
//
//  Created by Chester Shen on 7/30/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowPanoramaPage: GuideBasicPage {
    weak var detailVC: HNCameraDetailViewController?
    var hudView = PassThroughView()
    var maskView = PassThroughView()
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? PassThroughView)?.hitDelegate = self
        view.addSubview(maskView)
        actionTitle = NSLocalizedString("Next", comment: "Next")
        let gesutre = UIImageView(image: #imageLiteral(resourceName: "pinch_gesture"))
        let label = UILabel()
        gesutre.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        hudView.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.text = NSLocalizedString("Pinch and drag", comment: "Pinch and drag")
        hudView.addSubview(gesutre)
        hudView.addSubview(label)
        gesutre.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true
        gesutre.topAnchor.constraint(equalTo: hudView.topAnchor, constant: 10).isActive = true
        gesutre.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true
        label.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: hudView.bottomAnchor, constant: -6).isActive = true
        label.leadingAnchor.constraint(equalTo: hudView.leadingAnchor, constant: 10).isActive = true
        hudView.layer.cornerRadius = 8
        hudView.layer.masksToBounds = true
        hudView.backgroundColor = UIColor.semanticColor(.background(.maskLight))
        maskView.addSubview(hudView)
        hudView.centerXAnchor.constraint(equalTo: maskView.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: maskView.centerYAnchor).isActive = true
    }

    override func viewDidLayoutSubviews() {
        refreshMask()
    }
    
    func refreshMask() {
        guard let panelView = detailVC?.playerPanel.view else { return }
        let passFrame = panelView.convert(panelView.bounds, to: view)
        maskView.frame = passFrame
        if detailVC!.playerPanel.fullScreen {
            controller?.background.alpha = 0
        } else {
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: view.bounds)
            path.append(UIBezierPath(rect: passFrame))
            maskLayer.fillRule = .evenOdd
            maskLayer.path = path.cgPath
            controller?.background.layer.mask = maskLayer
            controller?.background.alpha = 1
        }
    }
}

extension GuideShowPanoramaPage: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        guard let panel = detailVC?.playerPanel else { return false }
        let passFrame = panel.view.convert(panel.view.bounds, to: view)
        return passFrame.contains(point)
    }
}
