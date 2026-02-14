//
//  HNCModeDetectionViewController.swift
//  Acht
//
//  Created by forkon on 2019/2/18.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WaylensCameraSDK

class HNCSDrivingDetectingViewController: HNCSRadioChoiceBaseViewController<DrivingDetectionMethod> {
    @IBOutlet weak var testButton: UIButton!
    
    override var subTitle: String? {
        return NSLocalizedString("What decides if the car is driving", comment: "What decides if the car is driving")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initHeader(text: NSLocalizedString("Parking/Driving Detection", comment: "Parking/Driving Detection"), leftButton: true)
        
        testButton.addUnderline()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedChoice = DrivingDetectionMethod(trusted: camera?.local?.isMountACCTrusted ?? false)
        camera?.local?.getMountACCTrust()
    }

    override func applySettingsIfNeeded() {
        super.applySettingsIfNeeded()

        if selectedChoice == .vehiclePower {
            camera?.local?.setMountACCTrust(true)
        } else {
            camera?.local?.setMountACCTrust(false)
        }
        camera?.local?.getMountACCTrust()
    }
    
    @IBAction func testButtonTapped(_ sender: Any) {
        let vc = PCTCableTypeViewController.createViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HNCSDrivingDetectingViewController: WLCameraSettingsDelegate {
    
    func onGetMountACCTrust(_ trusted: Bool) {
        selectedChoice = trusted ? .vehiclePower : .vehicleMovement
    }
    
}

enum DrivingDetectionMethod {
    case vehiclePower
    case vehicleMovement

    init(trusted: Bool) {
        if trusted {
            self = .vehiclePower
        } else {
            self = .vehicleMovement
        }
    }
}

extension DrivingDetectionMethod: ChoiceItem {
    
    var name: String {
        switch self {
        case .vehiclePower:
            return NSLocalizedString("Vehicle power", comment: "Vehicle power")
        case .vehicleMovement:
            return NSLocalizedString("Vehicle movement", comment: "Vehicle movement")
        }
    }
    
    var description: String {
        switch self {
        case .vehiclePower:
            return NSLocalizedString("vehicle_power_description", comment: "More accurate, recommended for most vehicles, except electric/plug-in hybrid vehicles with OBD-Ⅱ cables.")
        case .vehicleMovement:
            return NSLocalizedString("vehicle_movement_description", comment: "Not as accurate but viable for all vehicles. Choose this method if your vehicle is electric or plug-in hybrid with OBD-Ⅱ cable.")
        }
    }
    
}
