//
//  HNPanGestureRecognizer.swift
//  Acht
//
//  Created by Chester Shen on 4/2/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class HNPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == .began) { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
