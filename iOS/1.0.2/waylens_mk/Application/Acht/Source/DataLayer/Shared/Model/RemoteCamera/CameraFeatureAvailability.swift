//
//  CameraFeatureAvailability.swift
//  Acht
//
//  Created by forkon on 2019/8/8.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

struct CameraFeatureAvailability<Camera> {
    private let camera: Camera

    init(_ camera: Camera) {
        self.camera = camera
    }
}

extension CameraFeatureAvailability where Camera: UnifiedCamera {

    var isNightVisionInDrivingModeAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.8.0") == true
    }

    var isMarkSpaceSettingsAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.9.0") == true
    }

    var isPowerCordTestAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.9.1") == true
    }

    var isAudioPromptSettingsAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.9.3") == true
    }

    var isNetworkDiagnosisAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.10") == true
    }

    var isAutoHDRAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.12.0") == true
    }

    var isAutoNightVisionAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.12.0") == true
    }

    var isUntrustACCWireSupportAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.12.0") == true
    }

    var isKeepAliveWhileAppConnectAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.12.0") == true
    }

    var isGPSInfoInVideoOverlayAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.13.06") == true
    }

    var isMultiInstallationModesAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return (camera.firmwareShort?.isNewerOrSameVersion(to: "1.13.06") == true) && (camera.local?.isSupportUpsideDown == true)
    }

    var isDrivingModeTimeoutSettingsAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return camera.firmwareShort?.isNewerOrSameVersion(to: "1.2.01") == true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true
    }

    var isProtectionVoltageAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return camera.firmwareShort?.isNewerOrSameVersion(to: "1.2.01") == true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true
    }

    var isAPNSettingsAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return camera.firmwareShort?.isNewerOrSameVersion(to: "1.2.01") == true
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true
    }

    var isSubStreamOnlyAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true
    }

    var isRiskyDriveDetectionWithGyroAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return true
        }
        return (camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true) && (camera.local?.isSupportRiskDriveEvent == true)
    }

    var isWlanModeAvailable: Bool {
        if camera.local?.productSerie == WLProductSerie.saxhorn {
            return false
        }
        return (camera.firmwareShort?.isNewerOrSameVersion(to: "1.14.0") == true) && (camera.local?.isSupportWlanMode == true)
    }

    var isVinMirrorAvailable: Bool {
        return camera.local?.productSerie == WLProductSerie.saxhorn
    }

    var isRecordConfigAvailable: Bool {
        return camera.local?.productSerie == WLProductSerie.saxhorn
    }

    var isDmsCameraCalibrationAvailable: Bool {
        guard camera.local?.productSerie == WLProductSerie.saxhorn else {
            return false
        }

        guard camera.firmwareShort?.isNewerOrSameVersion(to: "1.3.0") == true else {
            return false
        }

        return true
    }

    var isViewModeAvailable: Bool {
        if (camera.local == nil) && (camera.remote?.productionSerie == nil || camera.remote?.productionSerie == .some(.unknown)) {
            if camera.sn.hasPrefix("6B") || camera.sn.hasPrefix("3A") {
                return false
            }
            return true
        }
        else {
            return camera.needDewarp
        }
    }

}

protocol FeatureAvailable {
    associatedtype CameraType

    static var featureAvailability: CameraFeatureAvailability<CameraType>.Type { get set }
    var featureAvailability: CameraFeatureAvailability<CameraType> { get set }
}

extension FeatureAvailable {
    static var featureAvailability: CameraFeatureAvailability<Self>.Type {
        get {
            return CameraFeatureAvailability<Self>.self
        }
        set {
            // this enables using CameraFeatureAvailability to "mutate" camera type
        }
    }

    var featureAvailability: CameraFeatureAvailability<Self> {
        get {
            return CameraFeatureAvailability(self)
        }
        set {
            // this enables using CameraFeatureAvailability to "mutate" camera object
        }
    }
}

extension UnifiedCamera: FeatureAvailable {}
