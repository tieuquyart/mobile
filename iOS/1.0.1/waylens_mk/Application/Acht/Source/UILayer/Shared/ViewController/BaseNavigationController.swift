//
//  BaseNavigationController.swift
//  Acht
//
//  Created by Chester Shen on 6/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

//    override var shouldAutorotate: Bool {
//        return topViewController?.shouldAutorotate ?? true
//    }
    
   

    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return topViewController?.supportedInterfaceOrientations ?? .all
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return topViewController?.preferredStatusBarStyle ?? .lightContent
//    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Hide tabBar.
        if parent is UITabBarController, !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

}

extension BaseViewController {
    
    func addCloseButton() {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close_dark"), style: .plain, target: self, action: #selector(self.close))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}


