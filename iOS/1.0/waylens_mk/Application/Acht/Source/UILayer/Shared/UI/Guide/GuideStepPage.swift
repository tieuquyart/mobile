//
//  GuideStepPage.swift
//  Acht
//
//  Created by Chester Shen on 5/17/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideStepPage: GuidePage {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var text: String = "" {
        didSet {
            titleLabel?.text = text
        }
    }
    var actionTitle: String = NSLocalizedString("Go", comment: "Go") {
        didSet {
            actionButton?.setTitle(actionTitle, for: .normal)
        }
    }
    
    static func createViewController() -> GuideStepPage {
        let vc = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: "GuideStepPageV2")
        return vc as! GuideStepPage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        titleLabel.text = text
        actionButton.setTitle(actionTitle, for: .normal)
    }
    
    @IBAction func onAction(_ sender: Any) {
        controller?.onAction()
    }
    
    @IBAction func onSkip(_ sender: Any) {
        controller?.onSkip()
    }

}
