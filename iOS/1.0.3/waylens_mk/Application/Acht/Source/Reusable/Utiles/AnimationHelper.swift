//
//  AnimationHelper.swift
//  Acht
//
//  Created by Chester Shen on 3/30/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import Foundation

extension UIView {
    func showAnimated(_ duration: TimeInterval=0.3) {
        if self.isHidden {
            self.alpha = 0
            self.isHidden = false
        }
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        })
    }
    
    func hideAnimated(_ duration: TimeInterval=0.3) {
        if self.isHidden {
            return
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { (completed) in
            if completed {
                self.isHidden = true
            }
        }
    }
}
