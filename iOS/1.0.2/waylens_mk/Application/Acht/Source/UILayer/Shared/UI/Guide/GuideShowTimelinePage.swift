//
//  GuideShowTimelinePage.swift
//  Acht
//
//  Created by Chester Shen on 7/31/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowTimelinePage: GuideBasicPage {
    var detailVC: HNCameraDetailViewController?
    var cell: CameraTimeLineCell? {
        if let index = indexPath {
            return detailVC?.timeLineVerticalView?.collectionView.cellForItem(at: index) as? CameraTimeLineCell
        }
        return nil
    }
    var indexPath: IndexPath?
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
        guard let cell = cell else { return }
        let frame = truncate(cell.convert(cell.thumbnailArea.frame, to: view))
        let point = CGPoint(x: frame.midX, y: frame.midY)
        showHalo(center: point)
        showTapIndicator(point: CGPoint(x: point.x - 16, y: point.y + 34))

        #if FLEET
        let tip = NSLocalizedString("Tap to view and export", comment: "Tap to view and export")
        #else
        let tip = NSLocalizedString("Tap to view, export and delete", comment: "Tap to view, export and delete")
        #endif
        showTip(tip, center: CGPoint(x: point.x, y: point.y + 84))
    }
    
    func refreshMask() {
        guard let cell = cell else { return }
        let path = UIBezierPath(rect: view.bounds)
        let thumbnailFrame = truncate(cell.convert(cell.thumbnailArea.frame, to: view))
        path.append(UIBezierPath(roundedRect: thumbnailFrame, cornerRadius: 2))
        let lineFrame = truncate(cell.convert(cell.timeline.frame, to: view))
        path.append(UIBezierPath(roundedRect: lineFrame, cornerRadius: 2))
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

extension GuideShowTimelinePage: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        guard let cell = cell else { return false }
        let passFrame = truncate(cell.convert(cell.bounds, to: view))
        return passFrame.contains(point)
    }
}
