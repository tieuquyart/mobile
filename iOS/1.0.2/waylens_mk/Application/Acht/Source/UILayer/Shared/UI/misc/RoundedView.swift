//
//  RoundedView.swift
//  Acht
//
//  Created by Chester Shen on 5/31/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

@IBDesignable class RoundedView: UIView {

//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            refresh()
//        }
//    }
    
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
//        layer.cornerRadius = cornerRadius
    }
}
