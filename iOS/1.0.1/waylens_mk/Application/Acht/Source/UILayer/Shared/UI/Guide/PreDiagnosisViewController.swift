//
//  PreDiagnosisViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/3/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class PreDiagnosisViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    var message: String? = nil {
        didSet {
            messageLabel.text = message
        }
    }
    static func createViewController() -> PreDiagnosisViewController {
        let vc = PreDiagnosisViewController(nibName: "PreDiagnosisViewController", bundle: nil)
        return vc
    }
    
    func addToViewController(_ vc: UIViewController) {
        vc.view.addSubview(view)
        view.frame = vc.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.addChild(self)
        didMove(toParent: vc)
    }
    
    func removeSelfFromParent() {
        view.removeFromSuperview()
        removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
    }
}
