//
//  InfoBasicCameraViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/27/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

extension String {
    func localizeMk() -> String {
        return ConstantMK.language(str: self)
    }
}

class InfoBasicCameraViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var items: [InfoCameraMKModel] = []
    
    
    var camera: UnifiedCamera?
    let config = ApplyCameraConfigMK()
    var sig_stt = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showProgress()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "InfoBasicCameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InfoBasicCameraCollectionViewCell")
        collectionView.register(UINib(nibName: "InfoBasicCameraHeaderViewCV", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "InfoBasicCameraHeaderViewCV")
        collectionView.addShadow(offset: CGSize(width: 3, height: 4))
        
        config.camera =  camera
        camera?.local?.settingsDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            // Put your code which should be executed with a delay here
            config.buildTCVN(cmd: "TCVN_01", dict: ["value": "msg01"])
        }
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBack))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    @objc func leftBack(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        
        initHeader(text: NSLocalizedString("Thông tin cơ bản", comment: "Thông tin cơ bản"), leftButton: false)
        
        self.showNavigationBar(animated: animated)
        
        loadSignStatusCamera()
       
    }
    
    

    func setUI(model : TCVN01ModelDict) {
        
        self.hideProgress()
        
        let supplierCMRGSHT = InfoCameraMKModel(key: "Supplier CMRGSHT".localizeMk(), value: model.sup)
        let typeCMRGSHT  = InfoCameraMKModel(key: "Type CMRGSHT".localizeMk(), value: model.type)
        let licenseplates  = InfoCameraMKModel(key: "License Plates".localizeMk(), value: model.plateNum)
        let methodSpeedMeasurement  = InfoCameraMKModel(key: "Method Speed Measurement".localizeMk(), value: "\(model.spdMethod ?? 0)")
        let configuringPulse = InfoCameraMKModel(key: "Configuring Pulse".localizeMk(), value: "\(model.pulseCfg ?? 0)")
        let speedLimit = InfoCameraMKModel(key: "Speed Limit".localizeMk(), value: "\(model.spdLimit ?? 0)")
        let dateOfInstallation = InfoCameraMKModel(key: "Date Of Installation".localizeMk(), value: model.lastModified)
        let statusMemory = InfoCameraMKModel(key: "Status Memory".localizeMk(), value: model.memStt)
        let capacityMemory = InfoCameraMKModel(key: "Capacity Memory".localizeMk(), value: model.totalMem)
        let infomationDriverPresent = InfoCameraMKModel(key: "Infomation Driver Present".localizeMk(), value: model.curDriver)
        let timeOfCMRGSHT = InfoCameraMKModel(key: "Time Of CMRGSHT".localizeMk(), value: model.time)
        
        items = [supplierCMRGSHT,typeCMRGSHT,licenseplates,methodSpeedMeasurement,speedLimit,dateOfInstallation,configuringPulse,statusMemory,capacityMemory,infomationDriverPresent,timeOfCMRGSHT]

        self.collectionView.reloadData()
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
    
}


extension InfoBasicCameraViewController {
    
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

extension InfoBasicCameraViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoBasicCameraCollectionViewCell", for: indexPath) as! InfoBasicCameraCollectionViewCell
        let item = items[indexPath.item]
        cell.config(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
       switch kind {
                    
       case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "InfoBasicCameraHeaderViewCV", for: indexPath) as! InfoBasicCameraHeaderViewCV
           headerView.camerasnLabel.text = self.camera?.sn ?? "null"
                return headerView
                
         default:
           return UICollectionReusableView()
        }
    }
    
    
}

extension InfoBasicCameraViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 80)
    }

}


extension InfoBasicCameraViewController: WLCameraSettingsDelegate {
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
                self.setUI(model : model)
                
            }
        }
    }
    
}
