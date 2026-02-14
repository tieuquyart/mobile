//
//  UnsupportedCameraMonitor+Acht.swift
//  Acht
//
//  Created by forkon on 2020/5/8.
//  Copyright © 2020 waylens. All rights reserved.
//

import WaylensCameraSDK

extension UnsupportedCameraMonitor {

    var unsupportedCameraClassifier: UnsupportedCameraClassifier {
        return Secure360AppUnsupportedCameraClassifier()
    }

    func checkIfHasConnectedUnsupportedCamera(_ camerasToCheck: [Any]) {
        if let classifiableCameras: [WLCameraDevice] = camerasToCheck.filter({$0 is ClassifiableCamera}) as? [WLCameraDevice] {
            if !unsupportedCameraClassifier.classifyUnsupportedCameras(from: classifiableCameras).isEmpty {
                unsupportedCameraPrompter?.promptUnsupportedCamera()
            }
            else {
                if unsupportedCameraPrompter?.isPrompting == true {
                    unsupportedCameraPrompter?.dismissPrompt()
                }
            }
        }
    }
}

extension UIViewController: UnsupportedCameraPrompter {

    private struct AssociatedKeys {
        static var promptAlertController: UInt8 = 0
    }

    private var promptAlertController: UIAlertController? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.promptAlertController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.promptAlertController) as? UIAlertController
        }
    }

    var isPrompting: Bool {
        return promptAlertController != nil
    }

    func promptUnsupportedCamera() {
        guard promptAlertController == nil else {
            return
        }

        let appName = UIApplication.shared.wl.displayName

        let targetAppName = "Fleet"
        let message = String(format: NSLocalizedString("\"Waylens xx\" App is not for this camera.\nFor fleet customers, please use \"Waylens xx\" App.", comment: "\"Waylens %@\" App is not for this camera.\nFor fleet customers, please use \"Waylens %@\" App."), appName, targetAppName)

        func reset() {
            promptAlertController = nil
        }

        promptAlertController = topMostViewController.alert(title: NSLocalizedString("Sorry", comment: "Sorry"), message: message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: String(format: NSLocalizedString("Go to \"Waylens xx\" App", comment: "Go to \"Waylens %@\" App"), targetAppName), style: .default, handler: { _ in
                let appScheme = "com.waylens.Fleet://"

                if let appUrl = URL(string: appScheme), UIApplication.shared.canOpenURL(appUrl) {
                    UIApplication.shared.open(appUrl)
                }
                else {
                    let appstoreURL = URL(string: "itms-apps://apps.apple.com/us/app/waylens-fleet/id1475050298?ls=1")

                    if let appstoreURL = appstoreURL, UIApplication.shared.canOpenURL(appstoreURL) {
                        UIApplication.shared.open(appstoreURL, options: [:], completionHandler: nil)
                    }
                }

                reset()
            })
        })
    }

    func dismissPrompt() {
        promptAlertController?.dismissMyself(animated: true)
        promptAlertController = nil
    }

}

class Secure360AppUnsupportedCameraClassifier: UnsupportedCameraClassifier {

    func classifyUnsupportedCameras<CameraType>(from cameras: [CameraType]) -> [CameraType] where CameraType : ClassifiableCamera {
        if UserSetting.shared.access2BCamera {
            return []
        }
        else {
            return cameras.filter{$0.model?.hasPrefix("SC_V1") == true}
        }
    }

}
