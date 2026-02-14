//
//  RectDivider.swift
//  Acht
//
//  Created by forkon on 2020/6/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation

class RectDivider {
    private let rect: CGRect

    private(set) var remainder = CGRect.zero

    init(rect: CGRect) {
        self.rect = rect
        remainder = self.rect
    }

    @discardableResult
    func divide(atDistance: CGFloat, from fromEdge: CGRectEdge) -> CGRect {
        let divided = remainder.divided(atDistance: atDistance, from: fromEdge)
        remainder = divided.remainder
        return divided.slice
    }

    @discardableResult
    func divide(atPercent: CGFloat, from fromEdge: CGRectEdge) -> CGRect {
        var distance: CGFloat = 0.0

        switch fromEdge {
        case .minXEdge, .maxXEdge:
            distance = remainder.width * atPercent
        case .minYEdge, .maxYEdge:
            distance = remainder.height * atPercent
        }

        let divided = remainder.divided(atDistance: distance, from: fromEdge)
        remainder = divided.remainder
        return divided.slice
    }

    @discardableResult
    func divideOriginalRect(atPercent: CGFloat, from fromEdge: CGRectEdge) -> CGRect {
        var distance: CGFloat = 0.0

        switch fromEdge {
        case .minXEdge, .maxXEdge:
            distance = rect.width * atPercent
        case .minYEdge, .maxYEdge:
            distance = rect.height * atPercent
        }

        let divided = remainder.divided(atDistance: distance, from: fromEdge)
        remainder = divided.remainder
        return divided.slice
    }

}
