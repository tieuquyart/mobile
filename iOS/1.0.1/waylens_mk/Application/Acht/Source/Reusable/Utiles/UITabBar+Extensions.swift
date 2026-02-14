//
//  UITabBar+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/3/15.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UITabBar {
    
    func hideItemsTitle() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.clear], for: UIControl.State.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.clear], for: UIControl.State.highlighted)
        
        var offset: CGFloat = 6.0
        
        if #available(iOS 11.0, *), traitCollection.horizontalSizeClass == .regular {
            offset = 0.0
        }
        
        if let items = items {
            for item in items {
                item.imageInsets = UIEdgeInsets(top: offset, left: 0, bottom: -offset, right: 0);
            }
        }
    }
    
}
