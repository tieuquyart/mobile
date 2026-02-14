//
//  HNCSDebugPropViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/21/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class HNCSDebugPropViewController: BaseTableViewController, CameraRelated {

    var camera: UnifiedCamera?{
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var debugPropInput: UITextField!
    @IBOutlet weak var debugActionInput: UITextField!
    @IBOutlet weak var debugValueInput: UITextField!
    @IBOutlet weak var debugKeyInput: UITextField!
    @IBOutlet weak var debugResultLabel: UILabel!
    @IBOutlet weak var getButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Debug Property"
        debugPropInput.text = "camera.debug."
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.local?.settingsDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    @IBAction func onDebugPropSet() {
        self.debugResultLabel.text = "wait..."
        camera?.local?.doDebugProps(true, prop: self.debugPropInput.text!, action: self.debugActionInput.text!, value: self.debugValueInput.text!, key: self.debugKeyInput.text!)
    }
    @IBAction func onDebugPropGet() {
        camera?.local?.doDebugProps(false, prop: self.debugPropInput.text!, action: self.debugActionInput.text!, value: self.debugValueInput.text!, key: self.debugKeyInput.text!)
    }
}

extension HNCSDebugPropViewController: WLCameraSettingsDelegate {
    func onDebugProp(_ prop: String?, value: String?) {
        self.debugResultLabel.text = "Result: " + (value ?? "")
        self.debugPropInput.text = prop
        self.debugValueInput.text = value
        self.debugActionInput.text = ""
    }
}
