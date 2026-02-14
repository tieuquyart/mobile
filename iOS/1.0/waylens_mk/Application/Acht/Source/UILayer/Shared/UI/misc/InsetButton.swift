//
//  InsetButton.swift
//  Acht
//
//  Created by Chester Shen on 1/2/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class InsetButton: UIButton {
    var inset: UIEdgeInsets = .zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - inset.left,
            y: self.bounds.origin.y - inset.top,
            width: self.bounds.size.width + inset.left + inset.right,
            height: self.bounds.size.height + inset.top + inset.bottom
        )
        return newArea.contains(point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
