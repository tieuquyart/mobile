//
//  ApplyCameraAdasConfigMK.swift
//  Acht
//
//  Created by TranHoangThanh on 2/25/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import WaylensCameraSDK
import WaylensFoundation
import UIKit
import SSZipArchive


extension Notification.Name {
    
    public struct DownloadLog {
        static let download = Notification.Name(rawValue: "waylens.acht.notification.download")
        static let report = Notification.Name(rawValue: "waylens.acht.notification.report")
    }
    
    public struct ReloadNotiList {
        static let reload = Notification.Name(rawValue: "autosecure.mk.reload_noti")
    }
    
}



class ApplyCameraConfigMK {
    
    @objc var camera: UnifiedCamera? {
        didSet {
            updateCamera()
        }
    }
    
    let localModel = CTLLocalDataSource()
    let cloudModel = CTLCloudDataSource()
    
    private func updateCamera() {
        guard let camera = camera else { return }
        Log.info("Camera updated, to sn:\(camera.sn), hasLocal:\(camera.local != nil), \(camera)")
        localModel.camera = camera
        cloudModel.camera = camera
    }
    
    
    
    func in_out(dict : [String : Any]) {
        if let local = camera?.local {
            
            if var mkConfigDict = local.configDriverInfoMK {
                mkConfigDict["loginRQ"] = dict["loginRQ"]
                mkConfigDict["logoutRQ"] = dict["logoutRQ"]
                local.doSetConfigSettingMK(mkConfigDict, cmd: "in_out")
            } else {
                local.doSetConfigSettingMK(dict, cmd: "in_out")
            }
        } else {
            print("no find camera local")
        }
    }
    
    func getLog(date : String ) {
        if let local = camera?.local {
            local.copyLog(date)
        } else {
            print("no find camera local")
        }
    }
    
    func getDebugLog(){
        if let local = camera?.local{
            local.copyDebugLog()
        }else{
            print("no find camera local")
        }
    }
    
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString).zip"
        return path
    }
    
    func tempUnzipPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString)"
        let url = URL(fileURLWithPath: path)
        print("url unzip , \(url)")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("no unzip")
            return nil
        }
        
        return path
    }
    
    
    func downLoadingLog(value : String) {
        if let local = camera?.local {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
                local.downloadLog(progress: { progress in
                    print("progress ",progress )
                    
                    let progressDict:[String: Float] = ["progess": progress]
                    
                    // Post a notification
                    NotificationCenter.default.post(name: Notification.Name.DownloadLog.download, object: nil,userInfo: progressDict)
                    
                }, destination: {
                    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    
                    
                    let sourceURL = documentsUrl.appendingPathComponent("\(value).txt")
                    
                    
                    
                    return sourceURL
                }, date: value) {  b, sourceURL, err in
                    
                    let pathDict:[String: Any] = [
                        "success": b ,
                        "filePath": sourceURL?.path ?? ""
                    ]
                    
                    NotificationCenter.default.post(name: Notification.Name.DownloadLog.download, object: nil,userInfo: pathDict)
                    
                }
            })
            
            
        } else {
            print("no find camera local")
        }
    }
    
    func downLoadingDebugLog(value : String) {
        if let local = camera?.local {
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
                local.downloadDebugLog(progress: { progress in
                    print("progress ",progress )
                    
                    let progressDict:[String: Float] = ["progess": progress]
                    
                    // Post a notification
                    NotificationCenter.default.post(name: Notification.Name.DownloadLog.report, object: nil,userInfo: progressDict)
                    
                }, destination: {
                    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    
                    
                    let sourceURL = documentsUrl.appendingPathComponent("cameraDebugLogs.zip")
                    
                    return sourceURL
                }) {  b, sourceURL, err in
                    
                    let pathDict:[String: Any] = [
                        "success": b ,
                        "filePath": sourceURL?.path ?? ""
                    ]
                    
                    NotificationCenter.default.post(name: Notification.Name.DownloadLog.report, object: nil,userInfo: pathDict)
                    
                }
            })
            
            
        } else {
            print("no find camera local")
        }
    }
    
    func buildCheckCarrier() {
        
        if let local = camera?.local {
            local.doSetConfigSettingMK(["value":"1"], cmd: "checkCarrier")
        } else {
            print("no find camera local")
        }
    }
    
    func buildSimData(dict : [String : Any]) {
        if let local = camera?.local {
            local.doSetConfigSettingMK(dict, cmd: "checkSimData")
        } else {
            print("no find camera local")
        }
    }
    
    func buildAddFace(dict : [String : Any]) {
        if let local = camera?.local {
            local.doSetConfigSettingMK(dict, cmd: "sendDataFW")
        } else {
            print("no find camera local")
        }
    }
    
    
    func buildRemoveFace(dict : [String : Any]) {
        if let local = camera?.local {
            local.doSetConfigSettingMK(dict, cmd: "sendDataFW")
        } else {
            print("no find camera local")
        }
    }
    
    
    
    
    
    func buildTCVN(cmd : String , dict : [String : Any]) {
        if let local = camera?.local {
            if var mkConfigDict = local.tcvn1Config {
                mkConfigDict["value"] = dict["value"]
                local.doSetConfigSettingMK(mkConfigDict, cmd: cmd)
            } else {
                local.doSetConfigSettingMK(dict, cmd: cmd)
            }
        } else {
            print("no find camera local")
        }
    }
    
    
    func buildImage(dict : [String : String]) {
        if let local = camera?.local {
            
            if var mkConfigDict = local.configDriverInfoMK {
                mkConfigDict["imgBase64"] = dict["imgBase64"]
                local.doSetConfigSettingMK(mkConfigDict, cmd: "sendFaceImage")
                
            } else {
                
                local.doSetConfigSettingMK(dict, cmd: "sendFaceImage")
            }
        } else {
            print("no find camera local")
        }
    }
    
    
    func build(dict : [String : Any]) {
        if let local = camera?.local {
            
            if var mkConfigDict = local.configDriverInfoMK {
                mkConfigDict["DriverName"] = dict["DriverName"]
                mkConfigDict["Driver_License_No"] = dict["Driver_License_No"]
                mkConfigDict["Plate_Number"] = dict["Plate_Number"]
                local.doSetConfigSettingMK(mkConfigDict, cmd: "setDriverInfo")
                
            } else {
                
                local.doSetConfigSettingMK(dict, cmd: "setDriverInfo")
            }
        } else {
            print("no find camera local")
        }
    }
    
    func lasted_modify(dict : [String : Any]) {
        if let local = camera?.local {
            
            if var mkConfigDict = local.configSetting_cfgMK {
                mkConfigDict["latest_modify"] = dict["latest_modify"]
                local.doSetConfigSettingMK(mkConfigDict, cmd: "setting_cfg")
            } else {
                // print("dict lasted_modify " , dict["lasted_modify"])
                local.doSetConfigSettingMK(dict, cmd: "setting_cfg")
            }
        } else {
            print("no find camera local")
        }
    }
    
    func configMOC(isMobile : Bool) {
        
        let mocKey = isMobile ? "mobile" : "auto";
        
        if let local = camera?.local {
            let dict : [String : Any] = ["MOC" : mocKey]
            local.doSetConfigSettingMK(dict, cmd: "MOC_method")
        } else {
            print("no find camera local")
        }
        
        
    }
    
}






