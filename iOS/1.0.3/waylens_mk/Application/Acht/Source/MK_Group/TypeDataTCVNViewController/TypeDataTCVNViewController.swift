//
//  TypeDataTCVNViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 3/28/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK



class TypeDataTCVNViewController: BaseViewController {
    var camera: UnifiedCamera?
    
    let config = ApplyCameraConfigMK()
    var sig_stt = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config.camera =  camera
        camera?.local?.settingsDelegate = self
        
        title = "Type Data TCVN"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSignStatusCamera()
    }
    
    deinit {
        print("deinit TypeDataTCVNViewController")
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
    
    
    @IBAction func dataBasic(_ sender: Any) {
        config.buildTCVN(cmd: "TCVN_01", dict: ["value": "msg01"])
        
    }
    
    @IBAction func timeWorkDriver(_ sender: Any) {
        config.buildTCVN(cmd: "TCVN_02", dict: ["value": "msg02"])
        
    }
    
    
    @IBAction func parkingStopTime(_ sender: Any) {
        config.buildTCVN(cmd: "TCVN_03", dict: ["value": "msg03"])
    }
    
    @IBAction func journeyCar(_ sender: Any) {
        config.buildTCVN(cmd: "TCVN_04", dict: ["value": "msg04"])
    }
    
    
    @IBAction func secondSpeedOfCar(_ sender: Any) {
        config.buildTCVN(cmd: "TCVN_05", dict: ["value": "msg05"])
    }
    
    
}

extension TypeDataTCVNViewController {
    
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


extension TypeDataTCVNViewController: WLCameraSettingsDelegate {
    func onGetConfigSettingMK(_ mkConfig: [AnyHashable : Any], cmd: String) {
        //print("cmd suucess " , cmd)
        
        //   self.alert(title: "Set \(cmd)", message: "Suucess")
        
        if let status = mkConfig as? [String: Any] {
            print("onGetTCVN ",status)
            print("cmd ",cmd)
           // print("cmd",cmd)
            if cmd == "TCVN_01" {
                
                var model = TCVN01ModelDict(status)
                model.memStt = sdcardMessage()
                model.totalMem = displayedBytes(camera?.sdcardUsageTotal)
                model.sigStt = self.sig_stt
                model.sn     = camera?.sn
                let vc = ShowInfoCameraMKController()
                vc.model = model
                vc.msg = "msg01"
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if cmd == "TCVN_02" {
                
                let model = TCVN02ModelDict(status)
                let vc = ShowInfoCameraMKController()
                vc.model2 = model
                vc.msg = "msg02"
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if cmd == "TCVN_03" {
                
                let model = TCVN03ModelDict(status)
                let vc = ShowInfoCameraMKController()
                vc.model3 = model
                vc.msg = "msg03"
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if cmd == "TCVN_04" {
                
                
                let model = TCVN04ModelDict(status)
                let vc = ShowInfoCameraMKController()
                vc.model4 = model
                vc.msg = "msg04"
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if cmd == "TCVN_05" {
                
                let model =  TCVN05ModelDict(status)
                let vc = ShowInfoCameraMKController()
                vc.model5 = model
                vc.msg = "msg05"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }
        
    }
}
