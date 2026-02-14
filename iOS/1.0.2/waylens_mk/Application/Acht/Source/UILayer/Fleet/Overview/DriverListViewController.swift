//
//  DriverListViewController.swift
//  Acht
//
//  Created by forkon on 2019/9/23.
//  Copyright © 2019 Maxim Bilan. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit

class DriverListViewController: MapFloatingSubPanelController {
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var viewBoundTable: UIView!
    var headerView: DriverListHeader!
    private var dataSource: DriverListDataSource!
    private var isFirstLoading: Bool = true
    lazy var sortBar: ItemPickerView<DriverSorter> = { [weak self] in
        var config = ItemPickerViewConfig()
        let sortBar = ItemPickerView<DriverSorter>(
            frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 38.0),
            layout: SortBarLayout(margins: UIEdgeInsets(top: 0.0, left: 6, bottom: 0.0, right: 16.0)),
            config: config,
            items: DriverSorter.allCases.filter{$0 != .name && $0 != .plateNumber},
            selectedItemChangeHandler: { selectedItem in
                self?.dataSource.sorter = selectedItem
                self?.tableView.reloadData()
            })
        sortBar.titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        sortBar.titleLabel.text = ""
        sortBar.autoresizingMask = [.flexibleWidth]
        sortBar.backgroundColor = .clear
        return sortBar
    }()
    override var positionConfigs: [FloatingSubPanelLayout.PositionConfig] {
        return [
            FloatingSubPanelLayout.PositionConfig(postion: .full, inset: self.view.safeAreaInsets.top + 30.0/* 30.0*/),
            /*FloatingSubPanelLayout.PositionConfig(postion: .half, inset: 306.0),*/
            FloatingSubPanelLayout.PositionConfig(postion: .tip, inset: self.view.safeAreaInsets.top + 65.0/*65.0*/)
        ]
    }
    override var isActive: Bool {
        didSet {
            dataSource.isActive = isActive
        }
    }
    override var position: FloatingPanelPosition {
        didSet {
            if position == .tip {
                hideFilterButton()
            } else {
                showFilterButton()
            }
        }
    }
    deinit {
        debugPrint("\(self) deinit")
    }
    var toggleSortBarHandler: (() -> ())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Overview", comment: "Overview")
        tableView.tableFooterView = UIView()
        headerView = DriverListHeader.createFromNib()
        headerView.frame = headerContainer.bounds
        headerView.backgroundColor = UIColor.white
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.toggleSortBarHandler = toggleSortBarHandler
        headerContainer.addSubview(headerView)
        self.tableView.tableHeaderView = self.sortBar
        dataSource = DriverListDataSource(tableView: tableView, headerView: headerView)
        dataSource.delegate = self
        self.view.layoutIfNeeded()
    }
    func presentInvalidAccessToken() {
        let alert = UIAlertController.init(title: NSLocalizedString("Invalid access token", comment: "Invalid access token"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Ok", comment: "Ok"), style: .default, handler: { (UIAlertAction) in
            SessionService.shared.logout(completion:nil)
            AccountControlManager.shared.keyChainMgr.onLogOut()
            AppViewControllerManager.gotoLogin()
        }))
        present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.backgroundColor = UIColor.white
        delegate?.viewController(self, dropPinsForVehicles: dataSource.vehicles)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    override func applyTheme() {
        super.applyTheme()
        sortBar.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        seperatorView.backgroundColor = UIColor.white
    }
    func showFilterButton() {
//        headerView.showFilterButton()
    }
    func hideFilterButton() {
//        headerView.hideFilterButton()
    }
    func showProgressWithRes(value: Bool){
        if value {
            SVProgressHUD.show()
        }else{
            SVProgressHUD.dismiss()
        }
    }
}
extension DriverListViewController: DriverListDataSourceDelegate {
    func dataSource(_ driverListDataSource: DriverListDataSource, didSelectDriver driver: Driver) {
        delegate?.viewController(self, showDetailOf: driver)
    }
    func dataSource(_ driverListDataSource: DriverListDataSource, didUpdateVehicles vehicles: [Vehicle]) {
        delegate?.viewController(self, dropPinsForVehicles: vehicles)
        if isFirstLoading {
            HNMessage.hideWhisper()
            isFirstLoading = false
        }
    }
    func presentMsg(msg: String) {
        if msg == "Invalid access token." {
            self.presentInvalidAccessToken()
        } else {
            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg), preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showProgressss(value: Bool) {
        self.showProgressWithRes(value: value)
    }
}
extension DriverListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let vehicle = (view.annotation as? VehicleAnnotation)?.vehicle {
            let driver = dataSource.drivers.first { (driver) -> Bool in
                return driver.vehicle.cameraSN == vehicle.cameraSN
            }
            if let driver = driver {
                delegate?.viewController(self, showDetailOf: driver)
            }
        }
    }
}
