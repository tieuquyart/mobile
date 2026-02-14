//
//  ShowInfoCameraMKController.swift
//  Acht
//
//  Created by TranHoangThanh on 3/3/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK
import LBTATools




class InfoCameraMKCell : LBTAListCell<InfoCameraMKModel> {
    
    let keyLabel :  UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.font = UIFont(name: "BeVietnamPro-Bold", size: 15)
        return label
    }()
    let valueLabel : UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.black
        label.textAlignment = .right
        label.numberOfLines = 2
        label.font =  UIFont(name: "BeVietnamPro-Medium", size: 13)
        return label
    }()
    
    override var item: InfoCameraMKModel! {
        didSet {
            keyLabel.text = item.key
            valueLabel.text = item.value
            hstack(keyLabel,valueLabel,spacing: 4,alignment: .leading).padLeft(16).padRight(16)
        }
    }
    
}




class ShowInfoCameraMKController: LBTAListController<InfoCameraMKCell,InfoCameraMKModel> , UICollectionViewDelegateFlowLayout {
    
    
    var model :  TCVN01ModelDict!
    var model2 : TCVN02ModelDict!
    var model3 : TCVN03ModelDict!
    var model4 : TCVN04ModelDict!
    var model5 : TCVN05ModelDict!
    var msg = ""
    
    var sig_stt = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSignStatusCamera()
       
    }
    
    
    func refresh(_ status: [String: String]) -> String {
        
        var s: String = ""
        
        if let signals = status["signal"]?.split(separator: ","),
           signals.count >= 3,
           let rsrp = Float(signals[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")) {
            s = "\(Int(rsrp)) dBm"
        } else if let csq = status["csq"]?.split(separator: ",") , csq.count >= 1 , let rssi = Int(csq[0]) {
            let dbm = -113 + rssi * 2
            if rssi == 0 {
                s = String(format: NSLocalizedString("%d dBm or less", comment: "%d dBm or less"), dbm)
            } else if rssi == 31 {
                s = String(format: NSLocalizedString("%d dBm or greater", comment: "%d dBm or greater"), dbm)
            } else {
                s = NSLocalizedString("No network", comment: "No network")
            }
        }
        
        return s
    }
    
    func loadSignStatusCamera() {
        if let status = camera?.local?.lteInfo as? [String: String] {
            print("status camera lteInfo")
            self.sig_stt = refresh(status)
        } else if camera?.viaWiFi ?? false {
            print("status camera viaWiFi")
            camera?.local?.settingsDelegate = self
            camera?.local?.getLTEStatus()
        } else {
            if let signalInfo = camera?.cellSignalInfo {
                print("status cellSignalInfo")
                self.sig_stt = "\(Int(signalInfo.rsrp)) dBm"
            }
        }
        
    }
    
    
    
    
    func setUI() {
        let supplierCMRGSHT = InfoCameraMKModel(key: "Supplier CMRGSHT", value: model.sup)
        let signalStatusMobile = InfoCameraMKModel(key: "Signal status mobile", value: model.sigStt)
        let typeCMRGSHT  = InfoCameraMKModel(key: "Type CMRGSHT", value: model.type)
        let seriNumberCMRGSHT = InfoCameraMKModel(key: "Seri Number CMRGSHT", value: model.sn)
        let licenseplates  = InfoCameraMKModel(key: "License Plates", value: model.plateNum)
        let methodSpeedMeasurement  = InfoCameraMKModel(key: "Method Speed Measurement", value: "\(model.spdMethod)")
        let configuringPulse = InfoCameraMKModel(key: "Configuring Pulse", value: "null")
        let speedLimit = InfoCameraMKModel(key: "Speed Limit", value: "\(model.spdLimit)")
        let dateOfInstallation = InfoCameraMKModel(key: "Date Of Installation", value: model.lastModified)
        let UpdateSoftwareNearest = InfoCameraMKModel(key: "Update Software Nearest", value: model.lastUpdated)
        let statusGPS  = InfoCameraMKModel(key: "Status GPS", value:"\(model.GPSStt)")
        let statusMemory = InfoCameraMKModel(key: "Status Memory", value: model.memStt)
        let capacityMemory = InfoCameraMKModel(key: "Capacity Memory", value: model.totalMem)
        let infomationDriverPresent = InfoCameraMKModel(key: "Infomation Driver Present", value: model.curDriver)
        let drivingTimeContinuity = InfoCameraMKModel(key: "Driving Time Continuity", value: "\(model.contDrvTime)")
        let infomationGPS = InfoCameraMKModel(key: "Infomation GPS/GNSS", value: model.GPSInfo)
        let speed = InfoCameraMKModel(key: "Speed", value: "\(model.speed)")
        let timeOfCMRGSHT = InfoCameraMKModel(key: "Time Of CMRGSHT", value: model.time)
        
        items = [supplierCMRGSHT,typeCMRGSHT,seriNumberCMRGSHT,licenseplates,methodSpeedMeasurement,configuringPulse,speedLimit,dateOfInstallation,UpdateSoftwareNearest,signalStatusMobile,statusGPS,statusMemory,capacityMemory,infomationDriverPresent,drivingTimeContinuity,infomationGPS,speed,timeOfCMRGSHT]
    }
    

    var camera: UnifiedCamera?
    let config = ApplyCameraConfigMK()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Device Information", comment: "Device Information")
        
    
        config.camera =  camera
        camera?.local?.settingsDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            // Put your code which should be executed with a delay here
            config.buildTCVN(cmd: "TCVN_01", dict: ["value": "msg01"])
        }
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "TCVN_01"), object: nil)

      //  setUI()
    }
    
    
    @objc func showResult(_ notification: NSNotification) {
        
        
        if let status = notification.userInfo as? [String: Any] {
            print("onGetTCVN ",status)
            // print("cmd",cmd)
            var model = TCVN01ModelDict(status)
            model.memStt = sdcardMessage()
            model.totalMem = displayedBytes(camera?.sdcardUsageTotal)
            model.sigStt = self.sig_stt
            model.sn     = camera?.sn
            self.model = model
            self.setUI()
        }

     }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 0, right: 0)
    }
}


extension ShowInfoCameraMKController {
    
    private func sdcardMessage() -> String? {
        if let state = camera?.local?.storageState {
            switch state {
            case .error:
                return WLCopy.sdcardError
            case .noStorage:
                return WLCopy.sdcardNotDetected
            case .ready:
                if camera?.local?.shouldFormat == true {
                    return WLCopy.sdcardFormatRecommended
                }
                return WLCopy.sdcardReady
            default:
                return nil
            }
        } else {
            return WLCopy.sdcardStateUnknown
        }
    }
    
    
    func displayedBytes(_ bytes: Int64?) -> String {
        if let bytes = bytes {
            return String.fromBytes(bytes, countStyle: .decimal)
        }
        return NSLocalizedString("Unknown", comment: "Unknown")
    }
    
}

extension ShowInfoCameraMKController: WLCameraSettingsDelegate {
    func onGetConfigSettingMK(_ mkConfig: [AnyHashable : Any], cmd: String) {
        if let status = mkConfig as? [String: Any] {
            print("onGetTCVN ",status)
            // print("cmd",cmd)
            if cmd == "TCVN_01" {
                
                var model = TCVN01ModelDict(status)
                model.memStt = sdcardMessage()
                model.totalMem = displayedBytes(camera?.sdcardUsageTotal)
                model.sigStt = self.sig_stt
                model.sn     = camera?.sn
                self.model = model
                self.setUI()
                
                
            }
        }
    }
    
}
