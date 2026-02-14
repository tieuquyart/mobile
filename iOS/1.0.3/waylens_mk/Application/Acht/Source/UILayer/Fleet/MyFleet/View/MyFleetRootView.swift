//
//  MyFleetRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class MyFleetRootView: ViewContainTableViewAndBottomButton {
    
    weak var ixResponder: MyFleetIxResponder?
    
    private let cameraRow = TableViewRow(
        image: FleetResource.Image.MyFleetIcon.connectCameraWiFi.image,
        title: NSLocalizedString("Kết nối Camera WiFi", comment: "Kết nối Camera WiFi"),
        detailViewControllerClass: HNCameraDetailViewController.self
    )
    
    
    private let typeDataMKCamera = TableViewRow (
        image: FleetResource.Image.MyFleetIcon.dataUsage.image,
        title: NSLocalizedString("Type Data TCVN", comment: "Type Data TCVN"),
        detailViewControllerClass: TypeDataTCVNViewController.self
    )
    
    
    private let configMKCamera =  TableViewRow (
        image: FleetResource.Image.MyFleetIcon.dataUsage.image,
        title: NSLocalizedString("Cấu hình Camera MK", comment: "Cấu hình Camera MK"),
        cellStyle: .value1,
        detailViewControllerClass: ConfigCameraMKViewController.self
    )
    
    private let getLogMKCamera = TableViewRow (
            image: FleetResource.Image.MyFleetIcon.connectCameraWiFi.image,
            title: NSLocalizedString("Nhật ký Camera MK", comment: "Nhật ký Camera MK"),
            detailViewControllerClass: GetLogViewController.self
    )
    
    
    
    private let configSimData = TableViewRow (
            image: FleetResource.Image.MyFleetIcon.connectCameraWiFi.image,
            title: NSLocalizedString("SimData MK", comment: "Simdata MK"),
            detailViewControllerClass: SimDataViewController.self
    )
    
    
    private let loginFaceRow = TableViewRow (
            image: FleetResource.Image.MyFleetIcon.personnelManagement.image,
            title: NSLocalizedString("Đăng nhập bằng khuôn mặt", comment: "Đăng nhập bằng khuôn mặt"),
            detailViewControllerClass: LoginFaceViewController.self
    )
    
    
    
    
    private var tableViewData: [TableViewSection] = [
        TableViewSection(items:
                            [
                                TableViewRow(
                                    image: #imageLiteral(resourceName: "Driver"),
                                    title: "",
                                    cellHeight: 88.0,
                                    detailViewControllerClass: MyFleetUserProfileViewController.self
                                ),
                                
                            ],
                         headerHeight: 0.001
                        ),
        TableViewSection(items:
                            [
                                //                                TableViewRow(
                                //                                    image: FleetResource.Image.MyFleetIcon.personnelManagement.image,
                                //                                    title: NSLocalizedString("Personnel Management", comment: "Personnel Management"),
                                //                                    detailViewControllerClass: PersonnelManagementViewController.self
                                //                                ),
//                                TableViewRow(
//                                    image: FleetResource.Image.MyFleetIcon.assetManagement.image,
//                                    title: NSLocalizedString("Asset Management", comment: "Asset Management"),
//                                    detailViewControllerClass: AssetManageViewController.self
//                                ),
                                
//                                TableViewRow(
//                                    image: FleetResource.Image.MyFleetIcon.assetManagement.image,
//                                    title: NSLocalizedString("Danh sách tài xế", comment: "Danh sách tài xế"),
//                                    detailViewControllerClass: DriverListController.self
//                                ),
//
//                                TableViewRow(
//                                    image: FleetResource.Image.MyFleetIcon.assetManagement.image,
//                                    title: NSLocalizedString("Danh sách Camera", comment: "Danh sách Camera"),
//                                    detailViewControllerClass: CameraListController.self
//                                ),
//
//
//                                TableViewRow(
//                                    image: FleetResource.Image.MyFleetIcon.assetManagement.image,
//                                    title: NSLocalizedString("Danh sách phương tiện", comment: "Danh sách phương tiện"),
//                                    detailViewControllerClass: VehicleListController.self
//                                ),
                                
                                
                                
                                //                                TableViewRow(
                                //                                    image: UIImage(named: "Profile_add camera"),
                                //                                    title: NSLocalizedString("Camera Install", comment: "Setup Camera"),
                                //                                    detailViewControllerClass: SetupStepOneViewController.self
                                //                                ),
                                
                                TableViewRow(
                                    image: FleetResource.Image.MyFleetIcon.album.image,
                                    title: NSLocalizedString("Album", comment: "Album"),
                                    detailViewControllerClass: HNAlbumViewController.self
                                )
                            ]
                        ),
        TableViewSection(items:
                            [
                                
                                TableViewRow(
                                    image: FleetResource.Image.MyFleetIcon.settings.image,
                                    title: NSLocalizedString("Settings", comment: "Settings"),
                                    detailViewControllerClass: MyFleetSettingsViewController.self
                                ),
                                
                                //                                TableViewRow(
                                //                                    image: FleetResource.Image.MyFleetIcon.shop.image,
                                //                                    title: NSLocalizedString("Shop", comment: "Shop"),
                                //                                    detailViewControllerClass: SafariViewController.self
                                //                                )
                            ]
                        )
    ]
    
    override init() {
        super.init()
       // CalibrationAdjustCameraPositionDependencyContainer().makeCalibrationAdjustCameraPositionViewController()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyFleetRootView: MyFleetUserInterface {
    
    //    func render(userProfile: UserProfile) {
    //        let userSectionItem = tableViewData[0].items[0]
    //        userSectionItem.title = userProfile.name
    //        tableView.reloadData()
    //    }
    
    func render(userProfile: UserProfile) {
        let userSectionItem = tableViewData[0].items[0]
        userSectionItem.title = userProfile.userName ?? ""
        tableView.reloadData()
    }
    
    func render(newCameraConnected: WLCameraDevice?) {
        
        if let newCameraConnected = newCameraConnected, newCameraConnected.productSerie != .unknown {
            if tableViewData[2].items[0] !== cameraRow {
                tableViewData[2].items.insert(cameraRow, at: 0)
                
            }
            
            if tableViewData[2].items[1] !== typeDataMKCamera {
                tableViewData[2].items.insert(typeDataMKCamera, at: 1)
                
            }
            //
            if tableViewData[2].items[2] !== configMKCamera {
                tableViewData[2].items.insert(configMKCamera, at: 2)
                
            }
            
            if tableViewData[2].items[3] !== getLogMKCamera {
                tableViewData[2].items.insert(getLogMKCamera, at: 3)
                
            }
            //
            
            if tableViewData[2].items[4] !== configSimData {
                tableViewData[2].items.insert(configSimData, at: 4)
                
            }
            
            if tableViewData[2].items[5] !== loginFaceRow {
                tableViewData[2].items.insert(loginFaceRow, at: 5)
                
            }
            
         
            
        } else {
            
            if tableViewData[2].items[0] === cameraRow {
                tableViewData[2].items.remove(at: 0)
            }
           // print("tableViewData[2].items",tableViewData[2].items.count)
            if tableViewData[2].items.count > 1 {

                if tableViewData[2].items[1] === typeDataMKCamera {
                    tableViewData[2].items.remove(at: 1)
                }

                if tableViewData[2].items[2] === configMKCamera {
                    tableViewData[2].items.remove(at: 2)

                }

                if tableViewData[2].items[3] === getLogMKCamera {
                    tableViewData[2].items.remove(at: 3)

                }
                
                
                if tableViewData[2].items[4] === configSimData {
                    tableViewData[2].items.remove(at: 4)

                }
                
                if tableViewData[2].items[5] === loginFaceRow {
                    tableViewData[2].items.remove(at: 5)

                }
                
                
                
            }
            
            
            
            
        }
        tableView.reloadData()
    }
    
}

//MARK: - Private

extension MyFleetRootView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewData[section].headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewData[indexPath.section].items[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableViewData[indexPath.section].items[indexPath.row]
        
        let cell: UITableViewCell = {
            let reuseIdentifier = "\(CellIdentifier.cell.rawValue)-\(item.cellStyle.rawValue)"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
                return item.cellType.init(style: item.cellStyle, reuseIdentifier: reuseIdentifier)
            }
            
            return cell
        }()
        
        cell.imageView?.contentMode = .center
        cell.textLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        cell.detailTextLabel?.font = cell.textLabel?.font
        cell.detailTextLabel?.textColor = UIColor.semanticColor(.tint(.primary))
        cell.separatorInset = UIEdgeInsets.zero
        
        cell.imageView?.image = item.image
        cell.textLabel?.text = item.title
        
        if item.detailViewControllerClass != nil {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = tableViewData[indexPath.section].items[indexPath.row]
        
        if let detailViewControllerClass = item.detailViewControllerClass {
            ixResponder?.navigateTo(viewController: detailViewControllerClass)
        }
        
    }
    
}


