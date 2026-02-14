//
//  ConfigCameraMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/22/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class ConfigCameraMKViewController: UIViewController {
    
    @IBOutlet weak var loginRQtf: UITextField!
    @IBOutlet weak var driverLicenceNo: UITextField!
    @IBOutlet weak var plateNumberTf: UITextField!
    @IBOutlet weak var driverNameTf: UITextField!
    @IBOutlet weak var logoutRQtf: UITextField!
    
    var camera: UnifiedCamera? {
        didSet {
            if !isViewLoaded { return }

            if camera != oldValue {
                
                reset()
            }

            updateCamera()
        }
    }
    
    private func reset(needsResetPosition: Bool = true) {
        sources.removeAll()
        localModel.camera = nil
        cloudModel.camera = nil
    }
    
    let config = ApplyCameraConfigMK()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var okLogout: UIButton!
    @IBOutlet weak var okLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        config.camera =  camera
        camera?.local?.settingsDelegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onGetConfig(_ sender: Any) {
       // config.getConfigIn_out()
     //   self.updateRecentThumbnail()
      
      // config.getConfig()
    }
    let localModel = CTLLocalDataSource()
    let cloudModel = CTLCloudDataSource()
    var sources = [HNVideoSource]()
    private func updateCamera() {
        guard let camera = camera else { return }
//        Log.info("Camera updated, to sn:\(camera.sn), hasLocal:\(camera.local != nil), \(camera)")
        localModel.camera = camera
        cloudModel.camera = camera
//        if camera.model?.hasPrefix("SAXHORN_") ?? false || camera.model?.hasPrefix("SH_") ?? false {
//            timeLineVerticalView?.layout.bufferedRatio = 3.0
//        }
//        if camera.model?.hasPrefix("LONGHORN_") ?? false || camera.model?.hasPrefix("LH_") ?? false {
//            timeLineVerticalView?.layout.bufferedRatio = 3.0
//        }
//        let wasLocalSource = isLocalSource
//        let previousLiveSource = playSourceView.items.first
//        sources.removeAll()
//        if camera.viaWiFi {
//            sources.append(.sdcard)
//        }


      ///  isLocalSource = sources.contains(.sdcard)



      

    }
    
    var timer: Timer?

    @IBAction func okSetDriverInfoBtnKey(_ sender: Any) {
        //updateConfigSetDriver()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked okSetDriverInfoBtnKey")
            self.updateConfigSetDriverKey()
        })
      
    }
    
    @IBAction func okSetDriverInfoBtn(_ sender: Any) {
        //  updateConfigSetDriverKey()
    }

    @IBOutlet weak var lastModifyTf: UITextField!
    @IBAction func okSettingCfg(_ sender: Any) {
        
        let dict : [String : Any] = [
            "latest_modify": "\(lastModifyTf.text ?? "")"
        ]
    
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked okSettingCfg")
            self.config.lasted_modify(dict: dict)
        })
        
    }
    
    func updateConfigSetDriverKey() {
        
        let dictSetup : [String : Any] = [
            "DriverName": "\(driverNameTf.text ?? "")",
            "Plate_Number": "\(plateNumberTf.text ?? "")",
            "Driver_License_No": "\(driverLicenceNo.text ?? "")"
        ]

        
        self.config.build(dict: dictSetup)
      
        
    }
    
    func updateOutRQ() {
        
        let dictSetup : [String : Any] = [
            "loginRQ": "",
            "logoutRQ": Int("\(logoutRQtf.text ?? "")"),
        ]
        
        config.in_out(dict: dictSetup)
    }
    
    func updateInRQ() {
        
        let dictSetup : [String : Any] = [
            "loginRQ": Int("\(loginRQtf.text ?? "")"),
            "logoutRQ": "",
        ]
        
        config.in_out(dict: dictSetup)
    }
    
    @IBAction func okLogin(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked okSettingCfg")
            self.updateInRQ()
        })
        
        
    }
    
    @IBAction func okLogOut(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked okSettingCfg")
            self.updateOutRQ()
        })
       
    }

}



extension ConfigCameraMKViewController :  WLCameraSettingsDelegate {
    func onCopyLog(_ value: Bool) {
        print("value onCopyLog",value)
    }
    
    func onGetConfigSettingMK(_ mkConfig: [AnyHashable : Any], cmd: String) {
        print("cmd Success " , cmd)
     
       self.showAlert(title: "Set \(cmd)", message: "Success")
        
//        if let status = mkConfig as? [String: Any] {
//            if cmd == "in_out" {
//               if let loginRQ = status["loginRQ"] as? Int , let logoutRQ = status["logoutRQ"] as? Int {
//                   if loginRQ == 1 {
//                        okLogin.isHidden = true
//                        okLogout.isHidden = false
//                   } else if logoutRQ == 1 {
//                       okLogout.isHidden = true
//                       okLogin.isHidden = false
//                   }
//               }
//            }
//        }
    }
    
}
