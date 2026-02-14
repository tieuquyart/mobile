//
//  WLActivityIndicator.swift
//  Acht
//
//  Created by Chester Shen on 8/16/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensAPNGKit
import WaylensFoundation

@IBDesignable class WLActivityIndicator: APNGImageView {
    @IBInspectable var isLight: Bool = false {
        didSet {
            if isLight != oldValue {
                finishInit()
            }
        }
    }
    
    @IBInspectable var hidesWhenStopped: Bool = false {
        didSet {
            if hidesWhenStopped && !isAnimating {
                isHidden = true
            }
            if isAnimating && isHidden {
                isHidden = false
            }
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        finishInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }
    
    private func finishInit() {
        if isLight {
            image = APNGImage(named: "logo_loading_light")
        } else {
            image = APNGImage(named: "logo_loading_dark")
        }
        backgroundColor = .clear
    }
    
    override func startAnimating() {
        Log.debug("Logo start animating")
        if isAnimating {
            return
        }
        if isHidden && hidesWhenStopped {
            isHidden = false
        }
        super.startAnimating()
    }
    
    override func stopAnimating() {
        Log.debug("Logo stop animating")
        if !isAnimating && isHidden {
            return
        }
        super.stopAnimating()
        if hidesWhenStopped {
            isHidden = true
        }
    }
    
}
