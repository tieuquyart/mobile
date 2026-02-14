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

//    let vehicleListController: VehicleListController = VehicleListController(itemInfo: IndicatorInfo(title: NSLocalizedString("Vehicles", comment: "Vehicles")))
//    let cameraListController: CameraListController = CameraListController(itemInfo: IndicatorInfo(title: NSLocalizedString("Devices", comment: "Devices")))
//    let driverLisrtController : DriverListController = DriverListController(itemInfo: IndicatorInfo(title: NSLocalizedString("Driver", comment: "Driver")))
//
//    override func viewDidLoad() {
//        settings.style.buttonBarBackgroundColor = UIColor.clear
//        settings.style.selectedBarHeight = 1.0
//        settings.style.selectedBarBackgroundColor = UIColor.semanticColor(.tint(.primary))
//        settings.style.buttonBarItemsShouldFillAvailableWidth = true
//        settings.style.buttonBarItemBackgroundColor = UIColor.clear
//        settings.style.buttonBarItemFont =  UIFont.boldSystemFont(ofSize: 14.0)
//        settings.style.buttonBarHeight = 44.0
//        settings.style.buttonBarMinimumInteritemSpacing = 0.0
//
//
//        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//
//            guard changeCurrentIndex == true else { return }
//
//            oldCell?.label.textColor = UIColor.semanticColor(.label(.secondary))
//
//            newCell?.label.textColor = UIColor.semanticColor(.tint(.primary))
//
//
//        }
//
//        super.viewDidLoad()
//        self.navigationController!.navigationBar.isTranslucent = false
//        title = NSLocalizedString("Asset Management", comment: "Asset Management")
//        applyTheme()
//        vehicleListController.delegate = self
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        return [cameraListController,vehicleListController,driverLisrtController]
//    }
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
extension AssetManageViewController: Themed {

    func applyTheme() {
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        settings.style.buttonBarItemTitleColor = UIColor.semanticColor(.label(.secondary))
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
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}


//


//class AssetManageViewController: ButtonBarPagerTabStripViewController {
//
//
//
//    let graySpotifyColor = UIColor(red: 21/255.0, green: 21/255.0, blue: 24/255.0, alpha: 1.0)
//    let darkGraySpotifyColor = UIColor(red: 19/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
//
//    override func viewDidLoad() {
//        // change selected bar color
//        settings.style.buttonBarBackgroundColor = graySpotifyColor
//        settings.style.buttonBarItemBackgroundColor = graySpotifyColor
//        settings.style.selectedBarBackgroundColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
//        settings.style.buttonBarItemFont = UIFont(name: "HelveticaNeue-Light", size:14) ?? UIFont.systemFont(ofSize: 14)
//        settings.style.selectedBarHeight = 3.0
//        settings.style.buttonBarMinimumLineSpacing = 0
//        settings.style.buttonBarItemTitleColor = .black
//        settings.style.buttonBarItemsShouldFillAvailableWidth = true
//
//        settings.style.buttonBarLeftContentInset = 20
//        settings.style.buttonBarRightContentInset = 20
//
//        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
//            guard changeCurrentIndex == true else { return }
//            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
//            newCell?.label.textColor = .white
//        }
//        super.viewDidLoad()
//        self.navigationController!.navigationBar.isTranslucent = false
//        title = "thanh"
//    }
//
//    // MARK: - PagerTabStripDataSource
//
//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let child_1 = TableChildExampleViewController(style: .plain, itemInfo: IndicatorInfo(title: "FRIENDS"))
//        child_1.blackTheme = true
//        let child_2 = TableChildExampleViewController(style: .plain, itemInfo: IndicatorInfo(title: "FEATURED"))
//        child_2.blackTheme = true
//        return [child_1, child_2]
//    }
//
//
//
//
//}
//
//
//
//
//class TableChildExampleViewController: UITableViewController, IndicatorInfoProvider {
//
//    let cellIdentifier = "postCell"
//    var blackTheme = false
//    var itemInfo = IndicatorInfo(title: "View")
//
//    init(style: UITableView.Style, itemInfo: IndicatorInfo) {
//        self.itemInfo = itemInfo
//        super.init(style: style)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
//        tableView.estimatedRowHeight = 600.0
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.allowsSelection = false
//        if blackTheme {
//            tableView.backgroundColor = UIColor(red: 15/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1.0)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
//
//    // MARK: - UITableViewDataSource
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return DataProvider.sharedInstance.postsData.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostCell,
//            let data = DataProvider.sharedInstance.postsData.object(at: indexPath.row) as? NSDictionary else { return PostCell() }
//
//        cell.configureWithData(data)
//        if blackTheme {
//            cell.changeStylToBlack()
//        }
//        return cell
//    }
//
//    // MARK: - IndicatorInfoProvider
//
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//}
//
//
//
//
