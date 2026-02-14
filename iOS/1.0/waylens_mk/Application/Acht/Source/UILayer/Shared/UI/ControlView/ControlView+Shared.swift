//
//  ControlView+Shared.swift
//  Acht
//
//  Created by forkon on 2018/9/7.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

enum ButtonFunction {
    case `default`
    case play
    case pause
}

extension UIButton {
    
    func setPlayAppearance() {
        setImage(UIImage(named: "playbar_play_n"), for: .normal)
        setImage(UIImage(named: "playbar_play_c"), for: .highlighted)
    }
    
    func setPauseAppearance() {
        setImage(UIImage(named: "playbar_pause_n"), for: .normal)
        setImage(UIImage(named: "playbar_pause_c"), for: .highlighted)
    }
    
    func setFullScreenAppearance() {
        setImage(UIImage(named: "playbar_screen_full_n"), for: .normal)
        setImage(UIImage(named: "playbar_screen_full_c"), for: .highlighted)
    }
    
    func setExitFullScreenAppearance() {
        setImage(UIImage(named: "playbar_screen_narrow_n"), for: .normal)
        setImage(UIImage(named: "playbar_screen_narrow_c"), for: .highlighted)
    }
    
    func setViewModeFrontBackAppearance() {
        setImage(#imageLiteral(resourceName: "btn_front back_n"), for: .normal)
        setImage(#imageLiteral(resourceName: "btn_front back_c"), for: .highlighted)
    }
    
    func setViewModePanoramaAppearance() {
        setImage(#imageLiteral(resourceName: "btn_panorama_normal_n"), for: .normal)
        setImage(#imageLiteral(resourceName: "btn_panorama_n"), for: .highlighted)
    }
    
    func setViewModeFrontBackFloatingAppearance() {
        setImage(#imageLiteral(resourceName: "180_black_button"), for: .normal)
        setImage(#imageLiteral(resourceName: "180_black_button_blue"), for: .highlighted)
    }
    
    func setViewModePanoramaFloatingAppearance() {
        setImage(#imageLiteral(resourceName: "360_black_button"), for: .normal)
        setImage(#imageLiteral(resourceName: "360_black_button_blue"), for: .highlighted)
    }
    func setViewModeShowDMSAppearance(show : Bool) {
        if show {
            setImage(#imageLiteral(resourceName: "icon_sign up_show password"), for: .normal)
            setImage(#imageLiteral(resourceName: "icon_sign up_show password"), for: .highlighted)
        } else {
            setImage(#imageLiteral(resourceName: "icon_sign up_close password"), for: .normal)
            setImage(#imageLiteral(resourceName: "icon_sign up_close password"), for: .highlighted)
        }
    }

    func setResolutionAppearance(resolution: HNVideoResolution? = nil) {
        if let resolution = resolution {
            setImage(nil, for: .normal)
            setImage(nil, for: .highlighted)

            switch resolution {
            case .sd:
                setTitle(HNVideoResolution.sd.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            case .hd:
                setTitle(HNVideoResolution.hd.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            case .frontHD:
                setTitle(HNVideoResolution.frontHD.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            case .incabinHD:
                setTitle(HNVideoResolution.incabinHD.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            case .dms:
                setTitle(HNVideoResolution.dms.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            default:
                setTitle(resolution.description, for: .normal)
                setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .highlighted)
            }
        }
        else {
            setTitle(nil, for: .normal)
            setImage(#imageLiteral(resourceName: "Switch"), for: .normal)
            setImage(#imageLiteral(resourceName: "Switch_selected"), for: .highlighted)
        }
    }

    func setResolutionFloatingAppearance(resolution: HNVideoResolution? = nil) {
        if let resolution = resolution {
            switch resolution {
            case .sd:
                setTitle(nil, for: .normal)
                setImage(#imageLiteral(resourceName: "sd_black_button"), for: .normal)
                setImage(#imageLiteral(resourceName: "sd_black_button_blue"), for: .highlighted)
            case .hd:
                setTitle(nil, for: .normal)
                setImage(#imageLiteral(resourceName: "hd_black_button"), for: .normal)
                setImage(#imageLiteral(resourceName: "hd_black_button_blue"), for: .highlighted)
            default:
                setImage(nil, for: .normal)
                setImage(nil, for: .highlighted)
                setResolutionAppearance(resolution: resolution)
            }
        }
        else {
            setImage(nil, for: .normal)
            setImage(nil, for: .highlighted)
            setResolutionAppearance()
        }
    }

}
