//
//  UITabBarController+HideTabBar.swift
//  Acht
//
//  Created by forkon on 2020/1/20.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

extension UITabBarController {

    private struct AssociatedKeys {
        // Declare a global var to produce a unique address as the assoc object handle
        static var originFrameOfView: UInt8 = 0
        static var movedFrameOfView: UInt8 = 1
    }

    var originFrameOfView: CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.originFrameOfView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.originFrameOfView, newValue, .OBJC_ASSOCIATION_COPY) }
    }

    var movedFrameOfView: CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.movedFrameOfView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.movedFrameOfView, newValue, .OBJC_ASSOCIATION_COPY) }
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let movedFrameView = movedFrameOfView {
            view.frame = movedFrameView
        }
    }

    func setTabBarVisible(visible: Bool, animated: Bool) {
        //since iOS11 we have to set the background colour to the bar color it seams the navbar seams to get smaller during animation; this visually hides the top empty space...
        view.backgroundColor = self.tabBar.barTintColor
    
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }

        //we should show it
        if visible {
            if #available(iOS 11.0, *) {
                additionalSafeAreaInsets = UIEdgeInsets.zero
            }

            UIView.animate(withDuration: animated ? TimeInterval(UINavigationController.hideShowBarDuration) : 0.0) {
                //restore form or frames
                self.view.frame = self.originFrameOfView!
                //errase the stored locations so that...
                self.originFrameOfView = nil
                self.movedFrameOfView = nil
                //...the layoutIfNeeded() does not move them again!
                self.view.layoutIfNeeded()
            }
        }
            //we should hide it
        else {
            //safe org positions
            originFrameOfView = view.frame
            // get a frame calculation ready
            let offsetY = self.tabBar.frame.size.height

            movedFrameOfView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)

            if #available(iOS 11.0, *) {
                additionalSafeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
            }

            //animate
            UIView.animate(withDuration: animated ? TimeInterval(UINavigationController.hideShowBarDuration) : 0.0, animations: {
                self.view.frame = self.movedFrameOfView!
                self.view.layoutIfNeeded()
            }) {
                (_) in

            }
        }
    }

    func tabBarIsVisible() -> Bool {
        return originFrameOfView == nil
    }
}
