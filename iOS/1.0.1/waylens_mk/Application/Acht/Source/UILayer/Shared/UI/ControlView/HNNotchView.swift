//
//  HNNotchView.swift
//  Acht
//
//  Created by forkon on 2018/9/11.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNNotchView: UIView {
    private enum Config {
        static let lineWidth: CGFloat = 1.0
    }
    fileprivate var line: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineHeight = bounds.height
        let lineOriginX = bounds.width / 2 - Config.lineWidth / 2
        line.frame = CGRect(x: lineOriginX, y: 0.0, width: Config.lineWidth, height: lineHeight)
    }
    
}

extension HNNotchView {
    
    fileprivate func setup() {
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
        
        line = UIView()
        line.backgroundColor = UIColor.semanticColor(.tint(.primary))
        addSubview(line)
    }
    
}
