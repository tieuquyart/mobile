//
//  GuideShowActionBarPage.swift
//  Acht
//
//  Created by Chester Shen on 7/31/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowActionBarPage: GuideBasicPage {
    var cell: CameraTimeLineCell? {
        if let index = indexPath {
            return detailVC?.timeLineVerticalView?.collectionView.cellForItem(at: index) as? CameraTimeLineCell
        }
        return nil
    }
    var indexPath: IndexPath?
    var detailVC: HNCameraDetailViewController?
    var cellHeight: CGFloat = 56
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? PassThroughView)?.hitDelegate = self
        actionButton.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        refreshMask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if FLEET
        guard let bar = detailVC?.clipInfoBar else { return }
        #else
        guard let bar = detailVC?.actionBar else { return }
        #endif
        let point = bar.convert(bar.infoButton.center, to: view)
        showHalo(center: point)
        showTapIndicator(point: CGPoint(x: point.x - 10, y: point.y + 6))
        showTip(NSLocalizedString("Tap to show more information", comment: "Tap to show more information"), center: CGPoint(x: point.x, y: point.y - 50))
    }
    
    func refreshMask() {
        #if FLEET
        guard let cell = cell, let bar = detailVC?.clipInfoBar else { return }
        #else
        guard let cell = cell, let bar = detailVC?.actionBar else { return }
        #endif

        let path = UIBezierPath(rect: view.bounds)
        let thumbnailFrame = truncate(cell.convert(cell.thumbnailArea.frame, to: view))
        let thumbnailPath = UIBezierPath(roundedRect: thumbnailFrame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 2, height: 2))
        path.append(thumbnailPath)
        let lineFrame = truncate(cell.convert(cell.timeline.frame, to: view))
        let linePath = UIBezierPath(roundedRect: lineFrame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 2, height: 2))
        path.append(linePath)

        let barFrame = bar.convert(bar.bounds, to: view)

        #if FLEET
        let barContainerFrameY = barFrame.minY - 8.0
        let barContainerFrame = CGRect(x: 0.0, y: barContainerFrameY, width: view.frame.width, height: view.frame.height - barContainerFrameY)
        skipButtonBottomSpace?.constant = -20 - barContainerFrame.height
        path.append(UIBezierPath(rect: barContainerFrame))
        #else
        skipButtonBottomSpace?.constant = -20 - barFrame.height
        path.append(UIBezierPath(rect: barFrame))
        #endif

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        controller?.background.layer.mask = maskLayer
    }
    
    private func truncate(_ rect: CGRect) -> CGRect {
        let top = detailVC?.timelineViewContainer.convert(CGPoint.zero, to: view).y ?? 0
        return CGRect(x: rect.minX, y: max(rect.minY, top), width: rect.width, height: min(rect.maxY - max(rect.minY, top), cellHeight))
    }
}

extension GuideShowActionBarPage: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        #if FLEET
        guard let bar = detailVC?.clipInfoBar else { return false }
        #else
        guard let bar = detailVC?.actionBar else { return false }
        #endif
        let passFrame = bar.convert(bar.bounds, to: view)
        return passFrame.contains(point)
    }
}
