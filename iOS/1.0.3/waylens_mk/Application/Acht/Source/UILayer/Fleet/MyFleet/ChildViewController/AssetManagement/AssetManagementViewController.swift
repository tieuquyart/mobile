//
//  AssetManagementViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AssetManagementViewController: ButtonBarPagerTabStripViewController {
    private let observer: Observer
    private let vehicleListViewController: VehicleListViewController
    private let cameraListViewController: CameraListViewController

    init(
        observer: Observer,
        vehicleListViewController: VehicleListViewController,
        cameraListViewController: CameraListViewController
    ) {
        self.observer = observer
        self.vehicleListViewController = vehicleListViewController
        self.cameraListViewController = cameraListViewController

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Asset Management", comment: "Asset Management")
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor.clear
        settings.style.selectedBarHeight = 1.0
        settings.style.selectedBarBackgroundColor = UIColor.semanticColor(.tint(.primary))
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemFont = UIFont(name: "BeVietnamPro-Bold", size: 14)!
        settings.style.buttonBarHeight = 44.0
        settings.style.buttonBarMinimumInteritemSpacing = 0.0
        
        

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = UIColor.semanticColor(.label(.secondary))
            newCell?.label.textColor = UIColor.semanticColor(.tint(.primary))
        }
        
       

        super.viewDidLoad()

        applyTheme()

        observer.startObserving()
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [vehicleListViewController, cameraListViewController]
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

//MARK: - Private

extension AssetManagementViewController: Themed {

    func applyTheme() {
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))

        settings.style.buttonBarItemTitleColor = UIColor.semanticColor(.label(.secondary))

        reloadPagerTabStripView()
    }

}

extension AssetManagementViewController: AssetManagementIxResponder {

}

extension AssetManagementViewController: ObserverForAssetManagementEventResponder {

    func received(newState: AssetManagementViewControllerState) {

    }

}

protocol AssetManagementViewControllerFactory {

}

//extension UIViewController: IndicatorInfoProvider {
//
//    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return IndicatorInfo(title: title)
//    }
//
//}
