//
//  EventLegendViewController.swift
//  Acht
//
//  Created by Chester Shen on 6/19/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class EventLegendViewController: UIViewController {
    @IBOutlet weak var timelineView: RoundedView!
    @IBOutlet weak var timelineTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var actionButton: UIButton!
    var dismissBlock: (()->Void)?

    @IBOutlet weak var behaviorStackView: UIStackView!

//    var timelineOffset: CGFloat = 270 {
//        didSet {
//            timelineTopSpace?.constant = timelineOffset
//        }
//    }
    static func createViewController() -> EventLegendViewController {
        let vc = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: "EventLegendViewController")
        return vc as! EventLegendViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        timelineTopSpace.constant = timelineOffset
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.white.cgColor
        actionButton.layer.cornerRadius = actionButton.bounds.height / 2
        // Do any additional setup after loading the view.

        #if !FLEET
        behaviorStackView.isHidden = true
        #endif
    }
    
    @IBAction func onExit(_ sender: Any) {
        dismissBlock?()
        dismiss(animated: true, completion: nil)
    }
}
