//
//  MKCameraInformationVC.swift
//  Fleet
//
//  Created by DevOps MKVision on 18/01/2024.
//  Copyright © 2024 waylens. All rights reserved.
//

import UIKit

class MKCameraInformationVC: BaseViewController {
    
    @IBOutlet weak var viewConnect : UIView!
    @IBOutlet weak var viewModemVersion : UIView!
    @IBOutlet weak var viewLogo : UIView!
    
    @IBOutlet weak var lbSerial : UILabel!
    
    @IBOutlet weak var lbModel : UILabel!
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var lbMountModel : UILabel!
    @IBOutlet weak var lbMountVersion : UILabel!
    @IBOutlet weak var lbDriverName : UILabel!
    @IBOutlet weak var lbModemVersion : UILabel!
    
    @IBOutlet weak var lbKModel : UILabel!
    @IBOutlet weak var lbKVersion: UILabel!
    @IBOutlet weak var lbKMountModel : UILabel!
    @IBOutlet weak var lbKMountVersion : UILabel!
    @IBOutlet weak var lbKDriverName : UILabel!
    @IBOutlet weak var lbKModemVersion : UILabel!
    
    @IBOutlet weak var lbNetwork : UILabel!
    
    
    @objc var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initHeader(text: NSLocalizedString("Device Information", comment: "Device Information"), leftButton: true)
        
        viewConnect.addTapGesture {
            let vc = HNCSNetworkViewController(style: .grouped)
            vc.camera = self.camera
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewLogo.addShadow(offset: CGSize(width: 3, height: 4))
        
        refreshUI()
    }

    func refreshUI(){
        //Key
        lbKModel.text = NSLocalizedString("Model", comment: "Model")
        lbKVersion.text = NSLocalizedString("Version", comment: "Version")
        lbKMountModel.text = NSLocalizedString("Mount Model", comment: "Mount Model")
        lbKMountVersion.text = NSLocalizedString("Mount Version", comment: "Mount Version")
        lbKDriverName.text = NSLocalizedString("Driver name", comment: "Driver name")
        lbNetwork.text = NSLocalizedString("Network", comment: "Network")
        
        //value
        lbSerial.text = camera?.sn
        lbModel.text = camera?.model
        lbVersion.text = camera?.firmwareShort
        lbMountModel.text = camera?.mountHwModel
        lbMountVersion.text = camera?.mountFwVersion
        lbDriverName.text = camera?.nameDriver
            
        if (camera?.local?.lteFirmwareVersionPublic) != nil {
            lbModemVersion.text = NSLocalizedString("Modem Version", comment: "Modem Version")
            lbModemVersion.text = camera?.local?.lteFirmwareVersionPublic
        }
        
    }
}
