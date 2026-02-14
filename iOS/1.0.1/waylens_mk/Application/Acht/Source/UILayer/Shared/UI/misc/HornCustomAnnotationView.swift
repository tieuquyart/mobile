//
//  HornCustomAnnotationView.swift
//  Acht
//
//  Created by gliu on 6/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import MapKit.MKAnnotationView

class HornCustomAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let icon = UIImageView.init(image: #imageLiteral(resourceName: "icon_location"))
        icon.center = self.center
        self.addSubview(icon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HornUserLocationAnnotationView: MKAnnotationView {
    let icon = UIImageView.init(image: #imageLiteral(resourceName: "icon_userlocation"))

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        icon.center = self.center
        self.addSubview(icon)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let animation = CABasicAnimation.init(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.toValue = 1.3
        animation.duration = 1.0
        animation.repeatCount = 10000
        animation.autoreverses = true
//        animation.fillMode = kCAFilterLinear
        icon.layer.add(animation, forKey: "Float")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
