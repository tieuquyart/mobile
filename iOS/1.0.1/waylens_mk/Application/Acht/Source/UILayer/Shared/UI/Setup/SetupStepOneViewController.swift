//
//  SetupStepOneViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class SetupStepOneViewController: BlankBaseViewController {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    static func createViewController() -> SetupStepOneViewController {
        let vc = UIStoryboard(name: "Setup", bundle: nil).instantiateViewController(withIdentifier: "SetupStepOneViewController")
        return vc as! SetupStepOneViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Camera Setup", comment: "Camera Setup")
        actionButton.setEnabled(enabled: false)
        actionButton.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCheck(_ sender: Any) {
        checkButton.isSelected = !checkButton.isSelected
        actionButton.setEnabled(enabled: checkButton.isSelected)
//        enableContinue(checkButton.isSelected)
    }

}
