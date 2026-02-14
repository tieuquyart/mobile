//
//  GuideCongratsPage.swift
//  Acht
//
//  Created by Chester Shen on 7/31/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideCongratsPage: GuideBasicPage {
    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? PassThroughView)?.hitDelegate = self
        skipButton.isHidden = true
        actionTitle = NSLocalizedString("Done", comment: "Done")
        text = NSLocalizedString("that_is_it_enjoy_owning_secure360", comment: "That's it!\nEnjoy the peace of mind that comes with owning a Secure360!")
    }
}

extension GuideCongratsPage: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
