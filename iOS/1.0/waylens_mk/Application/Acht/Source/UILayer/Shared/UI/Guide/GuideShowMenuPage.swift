//
//  GuideShowMenuPage.swift
//  Acht
//
//  Created by Chester Shen on 7/27/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideShowMenuPage: GuideBasicPage {
    var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let homeVC = ViewControllerUtils.homeVC else { return }
        guard let buttomImage = findButtonImage(under: homeVC.naviBar) else { return }
        let origin = buttomImage.convert(CGPoint.zero, to: homeVC.view.window)
        //            let origin = homeVC.naviBar.convert(CGPoint(x: 16, y: 6.7), to: homeVC.view.window)
        button = UIButton(frame: CGRect(x: origin.x, y: origin.y, width: 30, height: 30))
        let image = #imageLiteral(resourceName: "navbar_menu_n").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = WLStyle.decorationColor
        view.addSubview(button)
        button.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
        
        actionButton.isHidden = true
        showTapIndicator(point: CGPoint(x: button.frame.midX - 8, y: button.frame.maxY + 8))
        showHalo(center: CGPoint(x: button.frame.midX + 6, y: button.frame.midY + 6))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewIfNeeded()
        showTip(NSLocalizedString("Tap to open the menu", comment: "Tap to open the menu"), center: CGPoint(x: button.frame.midX - 8, y: button.frame.maxY + 60))
    }
    
    func findButtonImage(under view: UIView) -> UIImageView? {
        if view is UIImageView {
            guard view.bounds.size.height == 30, let homeVC = ViewControllerUtils.homeVC else { return nil }
            if view.convert(CGPoint.zero, to: homeVC.naviBar).x < 50 {
                return (view as! UIImageView)
            }
            return nil
        }
        for subview in view.subviews {
            if let imageView = findButtonImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
}

