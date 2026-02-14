//
//  DeviceViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/16/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import Parchment
import WaylensCameraSDK
class DeviceViewController: BaseViewController {
    var isConnectCamera : Bool = false
    var isSetting : Bool = false
    @IBOutlet weak var labelConnectCamera: UILabel!
    @IBOutlet weak var viewContainerConnectCamera: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var roleLabel: UILabel!
    let cameraObserver = ObserverForCurrentConnectedCamera()
    func setBorderView(view : UIView) {
       view.layer.cornerRadius = 10
       view.layer.masksToBounds = true
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
    }
    
    @IBOutlet weak var labelConectWifi: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.labelConectWifi.text = "Bấm để cài đặt wifi"
        self.labelConectWifi.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
        self.viewContainerConnectCamera.backgroundColor = UIColor.color(fromHex: ConstantMK.grayBG)
        cameraObserver.eventResponder = self
        
        cameraObserver.startObserving()
       
        roleLabel.text = UserSetting.current.userProfile?.fleetName
        setBorderView(view: viewContainerConnectCamera)
         let carControler = DriverListController()
       let  vehicleVC = VehicleListController()
       let cameraController = CameraListController()
        
        let viewControllers = [vehicleVC,cameraController,carControler]
        
       
        let pagingViewController = PagingViewController(viewControllers: viewControllers)
        pagingViewController.menuItemSize = .fixed(width: screenWidth / 3 , height: 40)
        pagingViewController.font = UIFont(name: SF_FONT_BOLD, size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        pagingViewController.selectedFont = UIFont(name: SF_FONT_BOLD, size: 12) ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        pagingViewController.selectedTextColor = UIColor.color(fromHex: ConstantMK.blueButton)
        pagingViewController.indicatorColor = UIColor.color(fromHex: ConstantMK.blueButton)
//
//        // Make sure you add the PagingViewController as a child view
//        // controller and constrain it to the edges of the view.
        addChild(pagingViewController)
        viewContainer.addSubview(pagingViewController.view)
        viewContainer.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        
        viewContainerConnectCamera.addTapGesture {
            if !self.isSetting {
                if self.isConnectCamera {
                    let vc = HNCameraDetailViewController.createViewController(camera: UnifiedCameraManager.shared.local,isCameraPickerEnabled: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.isSetting = true
                    self.showProgress()
                    UIApplication.shared.open(URL(string: "App-prefs:WIFI")!)
                }
            }
         
        }
    }

}


final class ContentViewController: UIViewController {
    convenience init(index: Int) {
        self.init(title: "View \(index)", content: "\(index)")
    }

    convenience init(title: String) {
        self.init(title: title, content: title)
    }

    init(title: String, content: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title

        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
        label.textColor = UIColor(red: 95 / 255, green: 102 / 255, blue: 108 / 255, alpha: 1)
        label.textAlignment = .center
        label.text = content
        label.sizeToFit()

        view.addSubview(label)
        view.constrainToEdges(label)
        view.backgroundColor = .white
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DeviceViewController : ObserverForCurrentConnectedCameraEventResponder {
    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        self.isSetting = false
        if let newCameraConnected = camera, newCameraConnected.productSerie != .unknown {
            self.labelConectWifi.text = "Bấm để kết nối\n \(camera?.sn ?? "")"
            self.isConnectCamera = true
            self.labelConectWifi.textColor = UIColor.color(fromHex: ConstantMK.greenLabel)
            self.viewContainerConnectCamera.backgroundColor = UIColor.color(fromHex: ConstantMK.greenBG)
            print("ket noi")
            self.hideProgress()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                print("done")
                self.hideProgress()
            })
            self.labelConectWifi.text = "Bấm để cài đặt wifi"
            self.isConnectCamera = false
            self.labelConectWifi.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
            self.viewContainerConnectCamera.backgroundColor = UIColor.color(fromHex: ConstantMK.grayBG)
          }
    }
}
