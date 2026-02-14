//
//  GuideWelcomePage.swift
//  Acht
//
//  Created by Chester Shen on 5/16/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideWelcomePage: GuidePage {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    var titleText: String?
    var detailText: String?
    var attributedText: NSAttributedString?
    var image: UIImage?
    var buttonText: String?
    
    static func createViewController(title: String?, detail: String?=nil, attributedDetail: NSAttributedString?=nil, image: UIImage?, button: String?) -> GuideWelcomePage {
        let vc = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: "GuideWelcomePage") as! GuideWelcomePage
        vc.titleText = title
        vc.attributedText = attributedDetail
        vc.detailText = detail
        vc.image = image
        vc.buttonText = button
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        titleLabel.text = titleText
        if attributedText != nil {
            detailLabel.attributedText = attributedText
        } else {
            detailLabel.text = detailText
        }
        imageView.image = image
        if buttonText != nil {
            actionButton.setTitle(buttonText, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }
    
    @IBAction func onAction(_ sender: Any) {
        controller?.onAction()
    }
    
    @IBAction func onSkip(_ sender: Any) {
        controller?.onSkip()
    }

}
