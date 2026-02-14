//
//  PassThroughView.swift
//  Acht
//
//  Created by Chester Shen on 6/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol PassThroughViewDelegate: class {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool
}

class PassThroughView: UIView {
    weak var hitDelegate: PassThroughViewDelegate?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subView in subviews.reversed() {
            if let view = subView.hitTest(convert(point, to: subView), with: event), !subView.isHidden {
                return view
            }
        }
        if let delegate = hitDelegate, !delegate.shouldPassHit(point, with: event) {
            return self
        }
        return nil;
    }
}

class PassThroughImageView: UIImageView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subView in subviews.reversed() {
            if let view = subView.hitTest(convert(point, to: subView), with: event) {
                return view
            }
        }
        return nil;
    }
}
