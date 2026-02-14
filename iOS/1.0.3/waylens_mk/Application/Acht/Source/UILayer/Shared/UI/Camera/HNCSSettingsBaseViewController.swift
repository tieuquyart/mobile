//
//  HNCSSettingsBaseViewController.swift
//  Acht
//
//  Created by forkon on 2019/8/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class HNCSSettingsBaseViewController: BaseViewController, CameraRelated {

    @objc var camera: UnifiedCamera?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        camera?.local?.settingsDelegate = self as? WLCameraSettingsDelegate
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
        applySettingsIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    open func applySettingsIfNeeded() {

    }

    @objc private func handleApplicationDidEnterBackground() {
        applySettingsIfNeeded()
    }

}
