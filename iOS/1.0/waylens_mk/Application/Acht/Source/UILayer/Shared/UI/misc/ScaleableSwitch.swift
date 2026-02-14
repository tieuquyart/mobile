//
//  ScaleableSwitch.swift
//  Acht
//
//  Created by forkon on 2018/9/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class ScaleableSwitch: UISwitch {

    @IBInspectable var scale: CGFloat = 0 {
        didSet {
            refresh()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }
    
    internal func finishInit() {
        layer.masksToBounds = true
        refresh()
    }
    
    func refresh() {
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
}
