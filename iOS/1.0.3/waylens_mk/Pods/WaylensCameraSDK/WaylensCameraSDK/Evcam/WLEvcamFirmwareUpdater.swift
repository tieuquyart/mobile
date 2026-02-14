//
//  EvcamFirmwareUpdater.swift
//  Hachi
//
//  Created by forkon on 2018/12/17.
//  Copyright © 2018 Transee. All rights reserved.
//

import Foundation
import WaylensFoundation

@objc public class WLEvcamFirmwareUpdater: NSObject {
    fileprivate var progressClosure: ((_ progress: Int) -> Void)?
    fileprivate var successHandler: (() -> Void)?
    fileprivate var failureHandler: ((_ errorCode: Int) -> Void)?

    let cameraDevice: WLCameraDevice
    
    @objc public init(cameraDevice: WLCameraDevice) {
        self.cameraDevice = cameraDevice
        
        super.init()

        cameraDevice.firmwareUpgradeDelegate = self
    }
    
    @objc public func transferFirmware(_ firmwareFilePath: String, withProgress progressClosure: ((_ progress: Int) -> Void)?, successHandler: (() -> Void)?, failureHandler: ((_ errorCode: Int) -> Void)?) {
        self.progressClosure = progressClosure
        self.successHandler = successHandler
        self.failureHandler = failureHandler
        
        if let firmwareFile = EvcamFirmwareFile(filePath: firmwareFilePath) {
            cameraDevice.transferFirmware(firmwareFile.data, size: Int32(firmwareFile.size), md5: firmwareFile.md5, rebootNeeded: true)
        }
    }
    
}

extension WLEvcamFirmwareUpdater: WLCameraFirmwareUpgradeDelegate {
    
    public func onReadyToUpgrade() {
        
    }
    
    public func onUpgradeResult(_ process: Int32) {
        
    }
    
    public func onTransferFirmware(_ state: Int32, size firmwareSize: Int32, progress: Int32, errorCode: Int32) {
        switch (EvcamTransferFirmwareState(intValue: Int(state))!) {
        case .started:
            break;
        case .transferring:
            progressClosure?(Int(progress))
            break;
        case .checking:
            break;
        case .error:
            failureHandler?(Int(errorCode))
            break;
        case .done:
            successHandler?()
            break;
        }
    }
}

@objc class EvcamFirmwareFile: NSObject {
    private let fileURL: URL
    
    @objc let size: UInt64
    @objc let md5: String
    @objc var data: Data {
        return try! Data(contentsOf: fileURL)
    }
    
    @objc init?(filePath: String) {
        self.fileURL = URL(fileURLWithPath: filePath)
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        self.size = UInt64(fileData.count)
        self.md5 = FileUtil.getfileMD5(filePath)
        
        super.init()
    }
}
