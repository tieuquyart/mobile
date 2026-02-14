//
//  HNTitleField.swift
//  Acht
//
//  Created by Chester Shen on 12/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNTitleField: UITextField {
    var allowEdit: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
