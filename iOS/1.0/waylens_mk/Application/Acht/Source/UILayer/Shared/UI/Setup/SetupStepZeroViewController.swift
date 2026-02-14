//
//  SetupStepZeroViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/25/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class SetupStepZeroViewController: BlankBaseViewController {
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = skipButton
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSkip(_ sender: Any) {
        if let _ = presentingViewController {
            dismiss(animated: false, completion: nil)
        } else {
//            navigationController?.viewControllers[0].closeLeft(animated: false)
//            navigationController?.popToRootViewController(animated: false)
        }
    }
}
