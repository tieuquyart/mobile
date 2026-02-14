//
//  CameraPromotionViewController.swift
//  Acht
//
//  Created by forkon on 2019/3/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CameraPromotionViewController: BaseViewController {

    @IBOutlet weak var promotionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tuneLableLineSpacing()
    }
    
    @IBAction func learnMoreButtonTapped(_ sender: Any) {
        openBrowser(withURLString: UserSetting.shared.webServer.shopUrl)
    }
    
    private func tuneLableLineSpacing() {
        let attributedString = NSMutableAttributedString(string: promotionLabel.text!)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        promotionLabel.attributedText = attributedString
    }

}
