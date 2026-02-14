//
//  UIView+Mask.swift
//  Acht
//
//  Created by Chester Shen on 8/28/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
extension UIView {
    func inverseMask(roundedRect rect: CGRect, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        path.append(UIBezierPath(rect: self.bounds))
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func removeMask() {
        self.layer.mask = nil
    }
}
