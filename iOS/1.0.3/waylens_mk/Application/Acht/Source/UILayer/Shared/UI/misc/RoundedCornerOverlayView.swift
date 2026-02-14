//
//  RoundedCornerOverlayView.swift
//  Acht
//
//  Created by forkon on 2018/9/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class RoundedCornerOverlayView: RoundedView {

    override func finishInit() {
        super.finishInit()
        
        backgroundColor = UIColor.semanticColor(.background(.maskLight))
    }

}
