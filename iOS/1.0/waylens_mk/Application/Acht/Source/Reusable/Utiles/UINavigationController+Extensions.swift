//
//  UINavigationController+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/6/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UINavigationController {

    func popToViewControllerWhichIsKind(of viewControllerClass: AnyClass, animated: Bool) {
        let toVC = viewControllers.last{$0.isKind(of: viewControllerClass)}
        if let toVC = toVC {
            popToViewController(toVC, animated: animated)
        }
    }

}
