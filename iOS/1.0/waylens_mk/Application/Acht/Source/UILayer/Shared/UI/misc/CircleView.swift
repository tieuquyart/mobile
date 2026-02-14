//
//  CircleView.swift
//  Acht
//
//  Created by Chester Shen on 1/7/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width * 0.5;
        clipsToBounds = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let dx = point.x - center.x;
        let dy = point.y - center.y;
        let r = bounds.width * 0.5;
        if dx * dx + dy * dy < r * r + 0.01 {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}
