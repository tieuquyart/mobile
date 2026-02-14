//
//  MKCameraSettingVC.swift
//  Fleet
//
//  Created by DevOps MKVision on 18/01/2024.
//  Copyright © 2024 waylens. All rights reserved.
//

import UIKit

class MKCameraSettingVC: BaseViewController {
    
    @IBOutlet weak var viewDeviceInfo: UIView!
    @IBOutlet weak var viewFirmware: UIView!
    @IBOutlet weak var viewVehicleStatus: UIView!
    @IBOutlet weak var viewSDCard: UIView!
    @IBOutlet weak var viewCalib: UIView!
    @IBOutlet weak var viewPowerCord: UIView!
    
    @IBOutlet weak var lbDeviceInfo: UILabel!
    @IBOutlet weak var lbFirmware: UILabel!
    @IBOutlet weak var lbVehicleStatus: UILabel!
    @IBOutlet weak var lbSDCard: UILabel!
    @IBOutlet weak var lbCalib: UILabel!
    @IBOutlet weak var lbPowerCord: UILabel!
    
    @objc var camera: UnifiedCamera? {
        didSet {
            refreshUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initHeader(text: NSLocalizedString("Cấu hình", comment: "Cấu hình"), leftButton: true)
        
        setupUI()
    }
    
    func setupUI(){
        lbDeviceInfo.text = NSLocalizedString("Device Information", comment: "Device Information")
        lbFirmware.text = NSLocalizedString("Firmware", comment: "Firmware")
        
        lbVehicleStatus.text = NSLocalizedString("Parking/Driving Detection", comment: "Parking/Driving Detection")
        lbSDCard.text = NSLocalizedString("SD card", comment: "SD card")
        
        lbCalib.text = NSLocalizedString("Calib the Driving Facing Camera", comment: "Calib the Driving Facing Camera")
        
        lbPowerCord.text = NSLocalizedString("Power Cord", comment: "Power Cord")
        
        //onTap
        
        viewDeviceInfo.addTapGesture {
            let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "MKCameraInformationVC") as! MKCameraInformationVC
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewFirmware.addTapGesture {
            let vc = HNCSFirmwareViewController.createViewController()
            vc.camera = self.camera
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewVehicleStatus.addTapGesture {
            let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "HNCSDrivingDetectingViewController") as! HNCSDrivingDetectingViewController
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewSDCard.addTapGesture {
            let vc = HNCSSDCardViewController.createViewController()
            vc.camera = self.camera
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewCalib.addTapGesture {
            if self.camera?.featureAvailability.isDmsCameraCalibrationAvailable == true {
                CalibrationGuide(presenter: CalibrationGuidePresenter()).start()
            }
            else {
                self.alert(message: NSLocalizedString("firmware_out_of_date", comment: "Firmware out of date.\nPlease update your camera's firmware."))
            }
        }
        
        viewPowerCord.addTapGesture {
            self.performFleetCameraAction {
                _ = self.showPowerCordTestIfPossible()
            }
        }
    }

    func refreshUI(){
        
    }
    
    func performFleetCameraAction(_ action: () -> ()) {
        action()
    }
}
