//
//  AssetManageViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//
class AssetManageViewController: ButtonBarPagerTabStripViewController  {

}

extension AssetManageViewController : VehicleListControllerDelegate {
    func showView(model : VehicleItemModel) {
        let controller = EditCameraController(nibName: "EditCameraController", bundle: nil)
        controller.model = model
        controller.delegate = self
        self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
    }
    
    
}
extension AssetManageViewController : AddVehicleControllerDelegate {
    func reloadData() {
      //  vehicleListController.reloadData()
    }
    
    
}
extension AssetManageViewController {

    func applyTheme() {
        view.backgroundColor = UIColor.white
        settings.style.buttonBarItemTitleColor = UIColor.black
        reloadPagerTabStripView()
    }

}


private extension AssetManageViewController {
    
    func add(viewController : UIViewController , asChildViewController childController : UIViewController , direction : UIView.AnimationOptions) -> Void {
        viewController.addChild(childController)
        UIView.transition(with: viewController.view, duration: 0.3, options: direction, animations: {
            [viewController] in
            viewController.view.addSubview(childController.view)
        }, completion: nil)
        childController.view.frame = viewController.view.bounds
        childController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childController.didMove(toParent: viewController)
        
        applyTheme()
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}


